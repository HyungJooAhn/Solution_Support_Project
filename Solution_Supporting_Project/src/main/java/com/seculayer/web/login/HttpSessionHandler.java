package com.seculayer.web.login;

import java.util.Map;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import com.seculayer.web.common.Constants;

public class HttpSessionHandler implements HttpSessionListener {

	private static final Map<String, Object> UserLoginSessionInfo = LoginController.UserLoginSessionInfo;
	private static Logger logger = Logger.getLogger(HttpSessionHandler.class);
	
	public void sessionCreated(HttpSessionEvent se) {
		HttpSession session = se.getSession();
		
		ServletContext ac = session.getServletContext();
		Map<String,Object> userCtx = (Map<String,Object>)ac.getAttribute(Constants.USER_CONTEXT);
		logger.debug("ServlerContext UserInfo : " + userCtx);
	}

	public void sessionDestroyed(HttpSessionEvent se) {
		HttpSession session = se.getSession();
		ServletContext ac = session.getServletContext();
		
		String userId = (String)session.getAttribute(Constants.USER_ID);
		String sessionId = (String)session.getAttribute(Constants.SESSION_ID);
		Map<String,Object> userCtx = (Map<String,Object>)ac.getAttribute(Constants.USER_CONTEXT);
		
		UserLoginSessionInfo.remove(sessionId);//세션이 끊어질때(로그아웃 or session-timeout초과) 현재접속자현황에서 세션정보삭제
		//logger.debug(userId+"가 로그아웃했고 "+ UserLoginSessionInfo.size()+"개 세션이 접속중임다.");
				
		if(userId != null && userCtx != null) {
			Map<String,Object> ctxUserInfo = (Map<String,Object>)userCtx.get(userId);
			logger.debug("sessionDestroyed : [SESSION_ID : " + session.getId() + "], [USER_ID : " + session.getAttribute(Constants.USER_ID) + "]");
			logger.debug("ServeltContext UserInfo : " + ctxUserInfo);
			
			if(ctxUserInfo != null 
					&& StringUtils.equals((String)session.getAttribute(Constants.USER_IP), (String)ctxUserInfo.get(Constants.USER_IP))
					&& StringUtils.equals(session.getId(), (String)ctxUserInfo.get(Constants.SESSION_ID))) {
				userCtx.remove(userId);
			}
		}
	}
	
}
