package com.seculayer.web.login;

import java.util.Map;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import com.seculayer.web.common.Config;
import com.seculayer.web.common.Constants;
//import com.seculayer.web.common.License;

public class LoginInterceptor extends HandlerInterceptorAdapter {

	public static final String AJAX_HEADER_NAME = "X-Requested-With";
	public static final String AJAX_HEADER_VALUE = "XMLHttpRequest";

	private static Logger logger = Logger.getLogger(LoginInterceptor.class);
	
	Configuration AdminConfig = Config.getInstance().getConfiguration("AdminConfig");

	@Autowired private ServletContext ctx;
//	@Autowired private License license;
	
	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
		logger.debug("<============================================================");
		logger.debug(">>> RequestURI=["+request.getRequestURI()+"]");
		String uri = request.getRequestURI();
		
		if(uri.indexOf("/login.do") > -1 || uri.indexOf("/interface/") > -1 || uri.indexOf("/common/license") > -1) {
//			if (uri.indexOf("/login.do") > -1) {
//				boolean isLicense = license.isValid();
//				logger.debug("license check - " + isLicense);
//				if (!isLicense) {
//					request.setAttribute("license", license);
//					request.getRequestDispatcher(request.getContextPath() + "/common/license.do").forward(request, response);
//					return false;
//				}
//			}
			return true;
		}
		
//		logger.debug(">>> getLocalAddr=" + request.getLocalAddr());
//		logger.debug(">>> getLocalName=" + request.getLocalName());
//		logger.debug(">>> getRemoteAddr=" + request.getRemoteAddr());
//		logger.debug(">>> getRemoteHost=" + request.getRemoteHost());
		
		// session검사
		HttpSession session = request.getSession(false);
		
		if (session == null) {
			logger.debug(">>> Session is Null");
			if(isAjax(request))
				response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "");
			else
				response.sendRedirect(request.getContextPath() + "/login.do");
			
			return false;
		}
		
		Map<String,Object> userInfo = (Map<String,Object>)session.getAttribute(Constants.USER_SESSION);
		if (userInfo == null) {
			logger.debug(">>> Session UserInfo is null");
			if(isAjax(request))
				response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
			else
				response.sendRedirect(request.getContextPath() + "/login.do");
			
			return false;
		}
		
		// UserId가 존재할 경우 동일 user의 세션정보와 ServletContext정보(sessionId, ip) 체크
		// 다를 경우 현재 Session Invalidate
		Map<String,Object> userCtx = (Map<String,Object>)ctx.getAttribute(Constants.USER_CONTEXT);
		if (userCtx != null) {
			if(!AdminConfig.getBoolean("multiple_login")) {
				Map<String,Object> ctxUserInfo = (Map<String,Object>)userCtx.get(userInfo.get("user_id"));
				logger.debug(">>> Session UserInfo : user_id=" + session.getAttribute(Constants.USER_ID) + ", user_ip=" + session.getAttribute(Constants.USER_IP) + ", sessionId=" + session.getId());
				logger.debug(">>> ServletContext UserInfo : " + ctxUserInfo);
				
				if(ctxUserInfo != null) {
					if(!StringUtils.equals((String)session.getAttribute(Constants.USER_IP), (String)ctxUserInfo.get(Constants.USER_IP))) {
						logger.debug(">>> " + ctxUserInfo.get(Constants.USER_IP) + "에서 로그인하여 Seesion Invalidate...");
						session.invalidate();
						response.sendRedirect(request.getContextPath() + "/login.do");
						return false;
					}
					if(!StringUtils.equals(session.getId(), (String)ctxUserInfo.get(Constants.SESSION_ID))) {
						logger.debug(">>> 다른 SessionId로 로그인하여 Seesion Invalidate...");
						session.invalidate();
						response.sendRedirect(request.getContextPath() + "/login.do");
						return false;
					}
				}
			}
		}
		return true;
	}
	
	@Override
	public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {
	}
	
	@Override
	public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
		logger.debug("============================================================>");
	}
	
	public static boolean isAjax(HttpServletRequest request) {
		return AJAX_HEADER_VALUE.equals(request.getHeader(AJAX_HEADER_NAME));
	}
}
