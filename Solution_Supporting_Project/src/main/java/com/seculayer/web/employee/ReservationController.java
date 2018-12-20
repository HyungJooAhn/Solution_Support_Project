package com.seculayer.web.employee;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.commons.configuration.Configuration;
import org.apache.ibatis.session.SqlSession;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import com.seculayer.web.auth.AuthorizationManager;
import com.seculayer.web.common.Config;
import com.seculayer.web.common.Constants;
import com.seculayer.web.common.util.PagingUtil;
import com.seculayer.web.common.util.StringUtil;
import com.seculayer.web.framework.entity.JsonResultEntity;
import com.seculayer.web.framework.entity.ResultEntityFactory;
import com.seculayer.web.framework.util.TemplateAndPage;
import com.seculayer.web.employee.dao.ReservationDAO;


@Controller
@RequestMapping(value = "/reservation/")
public class ReservationController {
	

	@Autowired private SqlSession sqlSession;
	@Autowired private ResultEntityFactory reFac;
	@Autowired private HttpServletRequest req;
	@Autowired private ReservationService svc;

	final static String Menu			= "l_con5";
	final static String Template 	    = "/common/tpl/base_template";
	final static String PopupTemplate 	= "/common/tpl/popup_template";
	final static String VIEW_MAPPING_PATH = "/employee/";
	
	final static String MAIL_SERVER = "smtp.cafe24.com"; 
	final static String MAIL_SERVER_USERNAME = "tech@seculayer.co.kr"; 
	final static String MAIL_SERVER_ALL = "all@seculayer.co.kr"; 
	final static String MAIL_SERVER_PW = "admin@123"; 
	final int MAIL_SERVER_PORT = 465; 
	
	final static String UPLOAD_PATH = "reservation";
	
	Configuration AdminConfig = Config.getInstance().getConfiguration("AdminConfig");

	static Logger logger = Logger.getLogger(ReservationController.class);
	
	@RequestMapping(value = "reservation.do")
	public ModelAndView taxiiServerList (@RequestParam Map<String, Object> map, HttpServletRequest req) {
		AuthorizationManager.getInstance(sqlSession).setCommunityRoleList(req,sqlSession);
		String template = StringUtil.isEmpty(map.get("popup")) ? Template : PopupTemplate;	
		ModelAndView mv = new ModelAndView(template);
		
		String pageId = StringUtil.isEmpty(map.get("page_id")) ? "/employee/reservation" : (String)map.get("page_id");

		mv.addObject("menu_id", Menu + ".jsp");
		mv.addObject("page_id", pageId + ".jsp");
		mv.addObject("searchHiddenParam", PagingUtil.getSearchHiddenParam(map));
		
		ReservationDAO dao = sqlSession.getMapper(ReservationDAO.class);
		List<Map<String, Object>> calendarData = dao.selectCalendarData(map);
		
		mv.addAllObjects(map);
		mv.addObject("calendar_data", calendarData);
		
		return mv;
	}
	
	@RequestMapping(value = "reservation_form.html")
	public ModelAndView formPage(@RequestParam Map<String, Object> map, HttpSession session) {
		ModelAndView mv = TemplateAndPage.getTemplateAndPage(map, TemplateAndPage.PARTIAL_TEMPLATE, VIEW_MAPPING_PATH, "reservation_form");
		Date d = new Date();
		
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
		if(map.containsKey("selected_date")){
			mv.addObject("selected", true);
			mv.addObject("selected_date", map.get("selected_date"));
		}else{
			mv.addObject("selected", false);
		}
		mv.addObject("today", sdf.format(d).toString());
		mv.addObject("proc_id", session.getAttribute(Constants.USER_ID));
		mv.addObject("page_title", "회의실 예약");
		return mv;
	}
	
	
	@RequestMapping(value = "reservation_insert.do")
	public @ResponseBody JsonResultEntity insert(HttpSession session, @RequestBody Map<String, Object> map) {
		map.put("proc_id", session.getAttribute(Constants.USER_ID));

		String startTime = map.get("startHour") + ":" + map.get("startMin");
		String endTime = map.get("endHour") + ":" + map.get("endMin");
		map.put("start_time", startTime);
		map.put("end_time", endTime);
		
		try{
			svc.insert(map);
		}catch(Exception e){
			return reFac.getJsonResultEntityFromResultCd("ERR.COM.0001");
		}
		
			
		return reFac.getJsonResultEntityFromResultCd("SUC.COM.0005");
	}
	
	
	@RequestMapping(value = "reservation.json")
	public @ResponseBody JsonResultEntity getList(@RequestBody Map<String,Object> map) {
		Map<String, Object> calendarData = svc.select(map);
		return reFac.getJsonResultEntity(calendarData);
	}
	
	@RequestMapping(value = "reservation_update.do")
	public @ResponseBody JsonResultEntity update(HttpSession session, @RequestBody Map<String, Object> map) {
		String startTime = map.get("startHour") + ":" + map.get("startMin");
		String endTime = map.get("endHour") + ":" + map.get("endMin");
		map.put("start_time", startTime);
		map.put("end_time", endTime);
		
		map.put("proc_id", session.getAttribute(Constants.USER_ID));
		svc.update(map);

		return reFac.getJsonResultEntityFromResultCd("SUC.COM.0002");
	}
	
	@RequestMapping(value = "reservation_delete.do")
	public @ResponseBody JsonResultEntity delete(HttpSession session, @RequestBody Map<String, Object> map) {
		svc.delete(map);

		return reFac.getJsonResultEntityFromResultCd("SUC.COM.0003");
	}
	@RequestMapping(value = "reservation_check.json")
	public @ResponseBody JsonResultEntity reservationCheck(@RequestBody Map<String, Object> map) {
		
		ReservationDAO dao = sqlSession.getMapper(ReservationDAO.class);
		boolean replicationChk = false;
		
		List<Map<String, Object>> calendarData = dao.selectCalendarData(map);
		for(Map<String,Object> cmap : calendarData){
			if(!cmap.get("id").toString().equals(map.get("reservation_id").toString())){
				if(cmap.get("reservation_date").toString().equals(map.get("reservation_date").toString())){
					if("전체".equals(map.get("reservation_room").toString())){
						if(("1".equals(cmap.get("reservation_room").toString())) || ("2".equals(cmap.get("reservation_room").toString())) || ("전체".equals(cmap.get("reservation_room").toString()))){
							float sleft = 0.0f;
							float eleft = 0.0f;
							if("30".equals(cmap.get("startMin").toString())) sleft = 0.5f; 
							if("30".equals(cmap.get("endMin").toString())) eleft = 0.5f;
							
							float numStartTime = Integer.parseInt(cmap.get("startHour").toString()) + sleft;
							float numEndTime = Integer.parseInt(cmap.get("endHour").toString()) + eleft;
							
							float psleft = 0.0f;
							float peleft = 0.0f;
							if("30".equals(map.get("startMin").toString())) psleft = 0.5f; 
							if("30".equals(map.get("endMin").toString())) peleft = 0.5f;
							
							float pnumStartTime = Integer.parseInt(map.get("startHour").toString()) + psleft;
							float pnumEndTime = Integer.parseInt(map.get("endHour").toString()) + peleft;
							
							if((Float.compare(numStartTime, pnumStartTime) >= 0) && (Float.compare(numStartTime, pnumEndTime) < 0)){
								replicationChk = true;
							}
							if((Float.compare(numStartTime, pnumStartTime) < 0) && (Float.compare(numEndTime, pnumStartTime) > 0)){
								replicationChk = true;
							}
						}
					}else{
						if((cmap.get("reservation_room").toString().equals(map.get("reservation_room").toString())) || ("전체".equals(cmap.get("reservation_room").toString()))){
							float sleft = 0.0f;
							float eleft = 0.0f;
							if("30".equals(cmap.get("startMin").toString())) sleft = 0.5f; 
							if("30".equals(cmap.get("endMin").toString())) eleft = 0.5f;
							
							float numStartTime = Integer.parseInt(cmap.get("startHour").toString()) + sleft;
							float numEndTime = Integer.parseInt(cmap.get("endHour").toString()) + eleft;
							
							float psleft = 0.0f;
							float peleft = 0.0f;
							if("30".equals(map.get("startMin").toString())) psleft = 0.5f; 
							if("30".equals(map.get("endMin").toString())) peleft = 0.5f;
							
							float pnumStartTime = Integer.parseInt(map.get("startHour").toString()) + psleft;
							float pnumEndTime = Integer.parseInt(map.get("endHour").toString()) + peleft;
							
							if((Float.compare(numStartTime, pnumStartTime) >= 0) && (Float.compare(numStartTime, pnumEndTime) < 0)){
								replicationChk = true;
							}
							if((Float.compare(numStartTime, pnumStartTime) < 0) && (Float.compare(numEndTime, pnumStartTime) > 0)){
								replicationChk = true;
							}
						}
					}
				}
			}
		}
		return reFac.getJsonResultEntity(replicationChk);
	}
	
	@RequestMapping(value = "reservation_mail_send.do") 
	public void mailSender(HttpServletRequest request, ModelMap mo, @RequestBody Map<String, Object> map) throws AddressException, MessagingException, ParseException { 
		String day = getDay(map.get("reservation_date").toString());
		String dyear = Integer.toString(Integer.parseInt(map.get("reservation_date").toString().split("-")[0]));
		String dmon = Integer.toString(Integer.parseInt(map.get("reservation_date").toString().split("-")[1]));
		String dday = Integer.toString(Integer.parseInt(map.get("reservation_date").toString().split("-")[2]));
		String room = map.get("reservation_room").toString();
		String startTime = map.get("startHour").toString() + ":" + map.get("startMin").toString();
		String endTime = map.get("endHour").toString() + ":" + map.get("endMin").toString();
		String applicantPosition = map.get("reservation_applicant_position").toString();
		String applicant = map.get("reservation_applicant").toString();
		String reservationName = map.get("reservation_nm").toString();
		
		String subject = "";
		String body = "";
		if("".equals(map.get("reservation_id").toString())){
			subject = "[공지] " + dmon + "월 " + dday + "일" + day + " 회의실  사용건( " + startTime + "~" + endTime + " )[" + room + "호실]";
			body = "※ 본 메일은 발신 전용 메일입니다.\n\n\n안녕하십니까.\n" + applicantPosition + " " + applicant + "입니다.\n\n\n아래와 같은 사유로 회의실을 사용할 계획입니다.\n회의실 사용에 참고 바랍니다.\n\n\n* 일시 : " + dyear + "년" + dmon + "월 " + dday + "일" + day + " " + startTime + "~" + endTime + " [" + room + "호실]\n* 내용 : " + reservationName + "\n\n\n자세한 사항은 \"Intelligence Center\"를 참고하세요.\n감사합니다.";
		}else{
			subject = "[변경공지] " + dmon + "월 " + dday + "일" + day + " 회의실  사용건( " + startTime + "~" + endTime + " )[" + room + "호실]";
			body = "※ 본 메일은 발신 전용 메일입니다.\n\n\n안녕하십니까.\n" + applicantPosition + " " + applicant + "입니다.\n\n\n아래와 같이 회의실 사용 계획이 변경되었습니다.\n회의실 사용에 참고 바랍니다.\n\n\n* 일시 : " + dyear + "년" + dmon + "월 " + dday + "일" + day + " " + startTime + "~" + endTime + " [" + room + "호실]\n* 내용 : " + reservationName + "\n\n\n자세한 사항은 \"Intelligence Center\"를 참고하세요.\n감사합니다.";
		}
		 
		Properties props = System.getProperties();
		props.put("mail.smtp.host", MAIL_SERVER); 
		props.put("mail.smtp.port", MAIL_SERVER_PORT); 
		props.put("mail.smtp.auth", "true"); 
		props.put("mail.smtp.ssl.enable", "true");
		props.put("mail.smtp.ssl.trust", MAIL_SERVER);
		Session session = Session.getDefaultInstance(props, new javax.mail.Authenticator() { 
			String un = AdminConfig.getString("mail_server_id",MAIL_SERVER_USERNAME); 
			String pw = AdminConfig.getString("mail_server_pw",MAIL_SERVER_PW); 
			
			protected javax.mail.PasswordAuthentication getPasswordAuthentication() { 
				return new javax.mail.PasswordAuthentication(un, pw); 
				} 
			}); 
		//session.setDebug(true); //for debug 
		Message mimeMessage = new MimeMessage(session); 
		mimeMessage.setFrom(new InternetAddress("IC@seculayer.co.kr"));
		mimeMessage.setRecipient(Message.RecipientType.TO, new InternetAddress(MAIL_SERVER_ALL)); 
		mimeMessage.setSubject(subject); //제목셋팅 
		mimeMessage.setText(body); //내용셋팅
		Transport.send(mimeMessage);
		
	}
	public String getDay(String date) throws ParseException{
		String day = "" ;
	    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
	    Date nDate = dateFormat.parse(date);
	    Calendar cal = Calendar.getInstance();
	    cal.setTime(nDate);
	     
	    int dayNum = cal.get(Calendar.DAY_OF_WEEK);
	    switch(dayNum){
	    case 1:
	    	day = "(일)";
	    	break;
	    case 2:
	    	day = "(월)";
	    	break;
	    case 3:
	    	day = "(화)";
	    	break;
	    case 4:
	    	day = "(수)";
	    	break;
	    case 5:
	    	day = "(목)";
	    	break;
	    case 6:
	    	day = "(금)";
	    	break;
	    case 7:
	    	day = "(토)";
	    	break;
	    }
		return day;
	}
}
