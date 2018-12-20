package com.seculayer.web.login;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
//import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

//import org.apache.commons.codec.digest.DigestUtils;
import org.apache.commons.configuration.Configuration;
import org.apache.ibatis.session.SqlSession;
import org.apache.log4j.Logger;
import org.codehaus.jackson.map.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.support.RequestContextUtils;

import com.seculayer.web.auth.AuthorizationManager;
import com.seculayer.web.common.Config;
import com.seculayer.web.common.Constants;
import com.seculayer.web.common.MessageUtil;
import com.seculayer.web.common.util.ApplicationUtil;
import com.seculayer.web.common.util.DateTimeUtil;
import com.seculayer.web.common.util.StringUtil;
import com.seculayer.web.login.dao.LoginDAO;
//import com.seculayer.web.lic.dao.LicDAO;
//import com.seculayer.web.main.dao.MainDAO;
import com.seculayer.web.system.AuditService;

@Controller
public class LoginController {
	Configuration AdminConfig = Config.getInstance().getConfiguration("AdminConfig");
	Configuration AppConfig = Config.getInstance().getDefaultConfiguration();
	
	private static Map<String,Object> UserLoginFailInfo = new HashMap<String,Object>();
	public static Map<String,Object> UserLoginSessionInfo = new HashMap<String,Object>();//로그인한유저들과 그유저들의 세션들
	
	private static Logger logger = Logger.getLogger(LoginController.class);
	//private static Locale locale = Locale.getDefault();
	
	final static String FullsizeTemplate = "/common/tpl/fullsize_template";
	final static String PopupTemplate = "/common/tpl/popup_template";
	
	@Autowired private MessageUtil msgUtil;
	@Autowired private SqlSession sqlSession;
	@Autowired private AuditService auditSvc;
	
	//private String FAIL_CNT_KEY = "fail_cnt";
	
	/*
	@RequestMapping(value = "/interface/bypass.do")
	public ModelAndView bypass(HttpServletRequest request, HttpSession session) {
		ModelAndView mav = new ModelAndView("redirect:/index.do");
		String userId = AppConfig.getString("bypass_user_id","admin");
		String userIp = request.getRemoteAddr();
		
		LoginDAO dao = sqlSession.getMapper(LoginDAO.class);
		Map<String,Object> userInfo = dao.detailUserInfo(userId);
		
		if(userInfo == null || userInfo.isEmpty()){
			logger.info("login bypass fail.. userInfo is empty");
		}else{
			//현재접속자현황을 위한 정보
			Map<String, Object> LoginSessionInfo = new HashMap<String, Object>();
			LoginSessionInfo.put("user_id", userId);
			LoginSessionInfo.put("session", session);
			LoginSessionInfo.put("session_id", session.getId());
			
			UserLoginSessionInfo.put((String)session.getId(),LoginSessionInfo);
			//logger.debug(userId+"가 접속했고 "+UserLoginSessionInfo.size()+"개 세션이 접속중임다.");
			
			session.setAttribute(Constants.USER_SESSION, userInfo);
			session.setAttribute(Constants.USER_ID, userId);
			session.setAttribute(Constants.USER_IP, userIp);
			session.setAttribute(Constants.SESSION_ID, session.getId());
		}
		
		return mav;
	}
	*/
	
	@RequestMapping(value = "/index.do")
	public ModelAndView index(HttpServletRequest req, @RequestParam Map<String, Object> map) {
		
		HttpSession session = req.getSession();
		Map<String, Object> userInfo = (Map<String, Object>)session.getAttribute(Constants.USER_SESSION);
		map.put("user_id", userInfo.get("user_id"));
		
//		LicDAO licDao = sqlSession.getMapper(LicDAO.class);
//		List<Map<String,Object>>  noticeList = licDao.selectLicensePopUpList(map);
//		
//		String popupNoticeYn = "";
//		if(noticeList.size() > 0) popupNoticeYn = "?popupNotice=Y";
		
		if((Integer.parseInt(userInfo.get("role_id").toString()) == 2) || (Integer.parseInt(userInfo.get("role_id").toString()) == 7)){
			ModelAndView mav = new ModelAndView("redirect:/mon/dashboard_outer.do");
			return mav;
		}else{
			ModelAndView mav = new ModelAndView("redirect:/mon/dashboard.do");
			return mav;
		}
	}
	
	@RequestMapping(value = "/login.do")
	public ModelAndView login(@RequestParam Map<String, Object> map) {
		ModelAndView mav = new ModelAndView("/login/login");
		logger.debug(">>> login form");
		return mav;
	}

	@RequestMapping(value = "/login.do", method = RequestMethod.POST)
	public @ResponseBody Map<String,Object> loginProc(HttpServletRequest request, HttpSession session) throws Exception {
		ApplicationContext appContext = RequestContextUtils.getWebApplicationContext(request);
		
		//ModelAndView mv = new ModelAndView("redirect:/index.do");
		Map<String,Object> rsMap = new HashMap<String,Object>();
		
		int FAIL_RETRY_CNT = AdminConfig.getInt("login_retry_cnt");
		int FAIL_RETRY_TIME = AdminConfig.getInt("login_retry_time");

		logger.debug(">>> login");
		
//		logger.debug(">>> getLocalAddr=" + request.getLocalAddr());
//		logger.debug(">>> getLocalName=" + request.getLocalName());
//		logger.debug(">>> getRemoteAddr=" + request.getRemoteAddr());
//		logger.debug(">>> getRemoteHost=" + request.getRemoteHost());
		
		String userId   = request.getParameter("userId");
		String userPswd = request.getParameter("userPswd");
		String userIp = request.getRemoteAddr();
		String forceLogin = request.getParameter("forceLogin");
		
		logger.debug(String.format(">>> userId=[%s],userPswd=[%s]", userId, userPswd));
		
		// 사용자 정보
		LoginDAO dao = sqlSession.getMapper(LoginDAO.class);
		Map<String, Object> userInfo = dao.detailUserInfo(userId);
		
		// 로그인실패 정보
		Map<String,Object> failInfo = (Map<String,Object>)UserLoginFailInfo.get(userId);

		// 감사정보
		Map<String,Object> auditInfo = new HashMap<String,Object>();
		auditInfo.put("user_ip", userIp);
		auditInfo.put("log_cd", "4");	// COM_CODE[CS0034] : 로그인[4]

		// 로그인 실패 횟수 및 시간 체크
		logger.debug(">>> FailInfo : " + failInfo);
		if(failInfo != null &&
				StringUtil.getInt(failInfo.get("fail_cnt")) >= FAIL_RETRY_CNT &&
				DateTimeUtil.diffSec((String)failInfo.get("fail_time"), DateTimeUtil.getDate(DateTimeUtil.TYPE_DATETIME)) <= FAIL_RETRY_TIME * 60) { 
				
			auditInfo.put("log_title", msgUtil.getMessage("INF.MSG.LOG1002"));
			auditInfo.put("remark",  msgUtil.getMessage("INF.MSG.LOG1004", new Object[]{userId}));
			
			//mv.setViewName("/login/login");
			rsMap.put("RESULT_CODE", "INF.MSG.LOG0004");
			rsMap.put("RESULT_MSG", msgUtil.getMessage("INF.MSG.LOG0004", new Object[]{FAIL_RETRY_CNT, FAIL_RETRY_TIME}));
		}
		else {
			// 시간 경과 후 로그인일 경우 시간 재설정
			if(failInfo != null &&
					StringUtil.getInt(failInfo.get("fail_cnt")) > FAIL_RETRY_CNT &&
					DateTimeUtil.diffSec((String)failInfo.get("fail_time"), DateTimeUtil.getDate(DateTimeUtil.TYPE_DATETIME)) > FAIL_RETRY_TIME * 60) { 
				// 최종 실패시간 Clear
				failInfo.put("fail_time", DateTimeUtil.getDate(DateTimeUtil.TYPE_DATETIME));
			}

			if (userInfo == null) {			
				logger.debug(">>> UserInfo is Null");			
				// 감사 로그 설정
				auditInfo.put("log_title", msgUtil.getMessage("INF.MSG.LOG1002"));
				auditInfo.put("remark", msgUtil.getMessage("INF.MSG.LOG1005", new Object[]{userId}));

				rsMap.put("RESULT_CODE", "INF.MSG.LOG0002");
				rsMap.put("RESULT_MSG", msgUtil.getMessage("INF.MSG.LOG0002", null));
			} else if (ApplicationUtil.comEncrypt(userPswd).equals((String)userInfo.get("passwd"))) {

				logger.debug(">>> Password Check Success");
				logger.debug(">>> UserInfo : " + userInfo);
				
				// 승인된 IP인지 체크
				if(checkAuthIp(userId, userIp, (String)userInfo.get("auth_ip"))) {
					// ServletContext
					if(checkUserInfoToContext(session, userId, session.getId(), userIp) || "Y".equals(forceLogin)) {
						// 세션 설정
						
						//현재접속자현황을 위한 정보
						Map<String, Object> LoginSessionInfo = new HashMap<String, Object>();
						LoginSessionInfo.put("user_id", userId);
						LoginSessionInfo.put("session", session);
						LoginSessionInfo.put("session_id", session.getId());
						
						UserLoginSessionInfo.put((String)session.getId(),LoginSessionInfo);
						//logger.debug(userId+"가 접속했고 "+UserLoginSessionInfo.size()+"개 세션이 접속중임다.");

						session.setAttribute(Constants.USER_SESSION, userInfo);
						session.setAttribute(Constants.USER_ID, userId);
						session.setAttribute(Constants.USER_IP, userIp);
						session.setAttribute(Constants.USER_NAME, userInfo.get("user_nm"));
						session.setAttribute(Constants.SESSION_ID, session.getId());
						
						// ServletContext UserInfo 설정
						setUserInfoToContext(session, userId, session.getId(), userIp);
						
						// 실패 정보 Clear
						if(failInfo != null) UserLoginFailInfo.remove(userId);
	
						// Audit
						auditInfo.put("user_id", userId);
						auditInfo.put("log_title", msgUtil.getMessage("INF.MSG.LOG1001"));
						auditInfo.put("remark", userInfo.get("user_nm") + "[" + userId + "] LOGIN");
						
						logger.debug(">>> Session Setted.");
						
						rsMap.put("RESULT_CODE", "INF.MSG.LOG0001");
						rsMap.put("RESULT_MSG", msgUtil.getMessage("INF.MSG.LOG0001"));
						
						loginSuccPostProc(request, session, rsMap);
					}
					else {
						auditInfo.put("user_id", userId);
						auditInfo.put("log_title", msgUtil.getMessage("INF.MSG.LOG1002"));
						auditInfo.put("remark", msgUtil.getMessage("INF.MSG.LOG1006", new Object[] {userInfo.get("user_nm"), userId}));
						
						rsMap.put("RESULT_CODE", "INF.MSG.LOG0010");
						rsMap.put("RESULT_MSG", msgUtil.getMessage("INF.MSG.LOG0010"));
					}
				}
				else {
					// Audit
					auditInfo.put("user_id", userId);
					auditInfo.put("log_title", msgUtil.getMessage("INF.MSG.LOG1002"));
					auditInfo.put("remark", msgUtil.getMessage("INF.MSG.LOG1007", new Object[] {userInfo.get("user_nm"), userId}));
					
					rsMap.put("RESULT_CODE", "INF.MSG.LOG0011");
					rsMap.put("RESULT_MSG", msgUtil.getMessage("INF.MSG.LOG0011"));
				}
			} else {
				logger.debug(">>> Password Check Fail");
				
				rsMap.put("RESULT_CODE", "INF.MSG.LOG0002");
				rsMap.put("RESULT_MSG", msgUtil.getMessage("INF.MSG.LOG0002"));

				// 로그인 실패 정보 설정
				if(failInfo == null) {
					failInfo = new HashMap<String,Object>();
					failInfo.put("fail_cnt", 1);
					failInfo.put("fail_time", DateTimeUtil.getDate(DateTimeUtil.TYPE_DATETIME));
				}
				else {
					failInfo.put("fail_cnt", StringUtil.getInt(failInfo.get("fail_cnt")) + 1);
					failInfo.put("fail_time", DateTimeUtil.getDate(DateTimeUtil.TYPE_DATETIME));
					
					if(StringUtil.getInt(failInfo.get("fail_cnt")) >= 5) {
						rsMap.put("RESULT_CODE", "INF.MSG.LOG0003");
						rsMap.put("RESULT_MSG", msgUtil.getMessage("INF.MSG.LOG0003", new Object[] {FAIL_RETRY_CNT, FAIL_RETRY_TIME}));
					}
				}
				UserLoginFailInfo.put(userId, failInfo);
				
				// Audit
				auditInfo.put("log_title", msgUtil.getMessage("INF.MSG.LOG1002"));
				auditInfo.put("remark",  msgUtil.getMessage("INF.MSG.LOG1008", new Object[] {userId}));
			}
		}
		
		auditSvc.insert(auditInfo);
		
		return rsMap;
	}
	
//	private Map<String, Object> getLoginMenu(Object menuId){//////로그인시 시작페이지 설정		
//		MainDAO dao = sqlSession.getMapper(MainDAO.class);		
//		Map<String, Object> map = new HashMap<String, Object>();
//		
//		map.put("login_menu_id", (String)menuId);		
//		Map<String,Object> menuCodeInfo = dao.selectLoginMenu(map);
//		
//		return menuCodeInfo ;
//	}
		
	private boolean checkAuthIp(String userId, String curIp, String authIp) {
		boolean bAuth = false;
		
		if(StringUtil.isEmpty(authIp)) bAuth = true;
		else if(authIp.indexOf(curIp) > -1) bAuth  = true;

		return bAuth;
	}
	
	// ServletContext에 동일 아이디에 다른 로그인 정보 존재 체크
	private boolean checkUserInfoToContext(HttpSession session, String userId, String sessionId, String curIp) {
		if(AdminConfig.getBoolean("multiple_login")) return true;
		
		ServletContext ctx = session.getServletContext();
		
		Map<String,Map<String,Object>> userContext = (Map<String,Map<String,Object>>)ctx.getAttribute(Constants.USER_CONTEXT);
		if(userContext != null) {
			Map<String,Object> userInfo = userContext.get(userId);
			
			if( userInfo != null &&
					(!curIp.equals(userInfo.get(Constants.USER_IP)) || !sessionId.equals(userInfo.get(Constants.SESSION_ID))) ) {
				return false;
			}
		}

		return true;
	}
	
	// ServletContext에 사용자정보 설정(UserId, SessionId, userIP)
	private void setUserInfoToContext(HttpSession session, String userId, String sessionId, String curIp) {
		ServletContext ctx = session.getServletContext();
		
		Map<String,Map<String,Object>> userContext = (Map<String,Map<String,Object>>)ctx.getAttribute(Constants.USER_CONTEXT);
		if(userContext == null) {
			userContext = new HashMap<String,Map<String,Object>>();
			ctx.setAttribute(Constants.USER_CONTEXT, userContext);
		}
		
		Map<String,Object> userInfo = new HashMap<String,Object>();
		userInfo.put(Constants.USER_ID, userId);
		userInfo.put(Constants.USER_IP, curIp);
		userInfo.put(Constants.SESSION_ID, sessionId);
		
		userContext.put(userId, userInfo);
	}
	
	private void loginSuccPostProc(HttpServletRequest request, HttpSession session, Map<String,Object> rsMap) throws Exception {
		LoginDAO dao = sqlSession.getMapper(LoginDAO.class);

		Map<String,Object> userInfo = (Map<String,Object>)session.getAttribute(Constants.USER_SESSION);
		
		String userId = (String)userInfo.get("user_id");
		String roleId = StringUtil.get(userInfo.get("role_id"));
		
		//사용자 접속시간 등록
		dao.updqteUserLastConnDt(userId);

		//메뉴 정보 등록
		AuthorizationManager authManager = AuthorizationManager.getInstance(sqlSession);
		ObjectMapper mapper = new ObjectMapper();

		session.setAttribute("menuList", mapper.writeValueAsString(authManager.getSvcMenuList()));
		session.setAttribute("menuInfo", mapper.writeValueAsString(authManager.getUsableMenus(roleId)));

		//로그인시 시작페이지 설정
//		if(StringUtil.isNotEmpty (userInfo.get("login_menu_id") ) ){
//			
//			Map<String,Object> menuCodeInfo = getLoginMenu(userInfo.get("login_menu_id"));
//			
//			if(menuCodeInfo != null ){
//				rsMap.put("loginUrl",menuCodeInfo.get("flag1"));
//				rsMap.put("loginOpt",menuCodeInfo.get("flag2"));
//			}				
//		}else{				
//			rsMap.put("loginUrl", "/");
//			logger.debug(">>> MenuId is null");
//		}

		//공지사항 팝업 여부 설정
//		BoardDAO brdDao = sqlSession.getMapper(BoardDAO.class);	
//		List<Map<String,Object>>  noticeList = brdDao.selectBoardPopUpList();
//		if(noticeList.size() > 0) rsMap.put("popupNotice", "Y");
	}
	
	@RequestMapping("/logout.do")
	public ModelAndView logout(HttpServletRequest request, HttpSession session, @RequestParam Map<String, Object> map){
		
		logger.debug(">>> logout");
		
		Map<String, Object> userInfo = null;
		
		if(session != null) {
			userInfo = (Map<String, Object>)session.getAttribute(Constants.USER_SESSION);

			if(userInfo != null) {
				Map<String,Object> auditMap = new HashMap<String,Object>();
				auditMap.put("user_id", session.getAttribute(Constants.USER_ID));
				auditMap.put("log_cd", "5");	// COM_CODE[CS0034] : 로그아웃[5]
				auditMap.put("user_ip", request.getRemoteAddr());
				auditMap.put("log_title", msgUtil.getMessage("INF.MSG.LOG1003"));
				auditMap.put("remark", userInfo.get("user_nm") + "[" + userInfo.get("user_id") + "] LOGOUT");
				auditSvc.insert(auditMap);
			}

			session.invalidate();
		}
		
		ModelAndView mav = new ModelAndView("redirect:/login.do");
		return mav;
	}
	
}
