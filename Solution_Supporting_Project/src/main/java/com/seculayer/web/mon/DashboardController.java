package com.seculayer.web.mon;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import javax.xml.bind.JAXBException;

import org.apache.commons.configuration.Configuration;
import org.apache.ibatis.session.SqlSession;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;
import org.xml.sax.SAXException;

import com.seculayer.web.auth.AuthorizationManager;
import com.seculayer.web.common.Config;
import com.seculayer.web.common.Constants;
import com.seculayer.web.common.util.ConfigurationX;
import com.seculayer.web.framework.entity.JsonResultEntity;
import com.seculayer.web.framework.entity.ResultEntityFactory;
import com.seculayer.web.framework.util.TemplateAndPage;
import com.seculayer.web.tist.dao.ThreatInfoDAO;


@Controller
@RequestMapping(value = "/mon/")
public class DashboardController {
	
	
	@Autowired private SqlSession sqlSession;
	@Autowired private ResultEntityFactory reFac;
	@Autowired private HttpServletRequest req;
	@Autowired private DashboardService svc;
	
	private static ConfigurationX conf = new ConfigurationX(false);
	
	final static String Menu			= "l_con3";
	final static String Template 	    = "inteldashboard";
	final static String PopupTemplate 	= "/common/tpl/popup_template";
	final static String VIEW_MAPPING_PATH = "/mon/";
	final static String HOME_PATH = "/Seculayer/app/www_intel/ROOT/WEB-INF/";
//	final static String HOME_PATH = "C:/Users/HJ/Desktop/Workspace/00.[src_workspace]/401.[Intelligence_Center]/src/main/webapp/WEB-INF";
	
	final static String UPLOAD_PATH = "tist";
	
	Configuration AdminConfig = Config.getInstance().getConfiguration("AdminConfig");

	static Logger logger = Logger.getLogger(DashboardController.class);

	@RequestMapping(value = "dashboard.do")
	public ModelAndView dashboardMain (@RequestParam Map<String, Object> map, HttpServletRequest req) {
		AuthorizationManager.getInstance(sqlSession).setCommunityRoleList(req,sqlSession);

		ModelAndView mv = TemplateAndPage.getTemplateAndPage(map, Template, VIEW_MAPPING_PATH, "dashboard");
		
		return mv;
	}
	
	@RequestMapping(value = "dashboard_outer.do")
	public ModelAndView dashboardOuterMain (@RequestParam Map<String, Object> map, HttpServletRequest req) {
		AuthorizationManager.getInstance(sqlSession).setCommunityRoleList(req,sqlSession);

		ModelAndView mv = TemplateAndPage.getTemplateAndPage(map, Template, VIEW_MAPPING_PATH, "dashboard_outer");
		
		return mv;
	}
	
	@RequestMapping(value = "contents_status.json")
	public @ResponseBody JsonResultEntity getContentsStatus(@RequestBody Map<String,Object> map) {
		HashMap<String, Object> result = svc.getContentsStatus();
		return reFac.getJsonResultEntity(result);
	}
	
	@RequestMapping(value = "ti_status.json")
	public @ResponseBody JsonResultEntity getTIStatus(@RequestBody Map<String,Object> map) {
		HashMap<String, Object> result = svc.getTIStatus();
		return reFac.getJsonResultEntity(result);
	}
	
	@RequestMapping(value = "download_status.json")
	public @ResponseBody JsonResultEntity getDownloadStatus(@RequestBody Map<String,Object> map) {
		HashMap<String, Object> result = svc.getDownloadStatus();
		return reFac.getJsonResultEntity(result);
	}
	
	@RequestMapping(value = "issue_status.json")
	public @ResponseBody JsonResultEntity getIssueStatus(@RequestBody Map<String,Object> map) {
		HashMap<String, Object> result = svc.getIssueStatus();
		return reFac.getJsonResultEntity(result);
	}
	
	@RequestMapping(value = "reservation_list.json")
	public @ResponseBody JsonResultEntity getReservationList(@RequestBody Map<String,Object> map) {
		ArrayList<Map<String, Object>> result = svc.getReservationList(map);
		
		return reFac.getJsonResultEntity(result);
	}
	@RequestMapping(value = "board_status.json")
	public @ResponseBody JsonResultEntity getBoardStatus(@RequestBody Map<String,Object> map) {
		HashMap<String, Object> result = svc.getBoardStatus();
		
		return reFac.getJsonResultEntity(result);
	}
	
	@RequestMapping(value = "nation_latitude_longitude.json")
	public @ResponseBody JsonResultEntity getNationList(@RequestBody Map<String,Object> map) {
		ArrayList<HashMap<String, Object>> result = svc.getNationList();
		
		return reFac.getJsonResultEntity(result);
	}
	
	@RequestMapping(value = "nation_ip_list.json")
	public @ResponseBody JsonResultEntity getNationIPList(@RequestBody Map<String,Object> map) {
		ArrayList<HashMap<String, Object>> result = svc.getNationIPList();
		
		return reFac.getJsonResultEntity(result);
	}
	
	@RequestMapping(value = "today_visitor.json")
	public @ResponseBody JsonResultEntity getTodayList(HttpServletRequest request, @RequestBody Map<String,Object> map) {
		HttpSession session = request.getSession(true);
		
		String userIp = session.getAttribute(Constants.USER_IP).toString();
		String userId = session.getAttribute(Constants.USER_ID).toString();
		String userName = session.getAttribute(Constants.USER_NAME).toString();
		
		Map<String, Object> param = new HashMap<String, Object>();
		param.put("user_ip", userIp);
		param.put("user_id", userId);
		param.put("user_nm", userName);
		
		Map<String, Object> result = svc.getTodayList(param);
		
		return reFac.getJsonResultEntity(result);
	}
}
