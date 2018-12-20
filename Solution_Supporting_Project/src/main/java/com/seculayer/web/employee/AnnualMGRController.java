package com.seculayer.web.employee;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

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

import com.seculayer.web.auth.AuthorizationManager;
import com.seculayer.web.common.Config;
import com.seculayer.web.common.Constants;
import com.seculayer.web.common.util.PagingUtil;
import com.seculayer.web.common.util.StringUtil;
import com.seculayer.web.employee.dao.AnnualMGRDAO;
import com.seculayer.web.employee.dao.ReservationDAO;
import com.seculayer.web.framework.entity.JsonResultEntity;
import com.seculayer.web.framework.entity.ResultEntityFactory;
import com.seculayer.web.framework.util.TemplateAndPage;


@Controller
@RequestMapping(value = "/annual/")
public class AnnualMGRController {
	

	@Autowired private SqlSession sqlSession;
	@Autowired private ResultEntityFactory reFac;
	@Autowired private HttpServletRequest req;
	@Autowired private ReservationService svc;

	final static String Menu			= "l_con5";
	final static String Template 	    = "/common/tpl/base_template";
	final static String PopupTemplate 	= "/common/tpl/popup_template";
	final static String VIEW_MAPPING_PATH = "/employee/";
	
	final static String UPLOAD_PATH = "annual";
	
	Configuration AdminConfig = Config.getInstance().getConfiguration("AdminConfig");

	static Logger logger = Logger.getLogger(AnnualMGRController.class);
	
	@RequestMapping(value = "annual_management.do")
	public ModelAndView annualManagement (@RequestParam Map<String, Object> map, HttpServletRequest req) {
		AuthorizationManager.getInstance(sqlSession).setCommunityRoleList(req,sqlSession);
		String template = StringUtil.isEmpty(map.get("popup")) ? Template : PopupTemplate;	
		ModelAndView mv = new ModelAndView(template);
		
		String pageId = StringUtil.isEmpty(map.get("page_id")) ? VIEW_MAPPING_PATH + "annual_management" : (String)map.get("page_id");
		mv.addObject("menu_id", Menu + ".jsp");
		mv.addObject("page_id", pageId + ".jsp");
		mv.addObject("searchHiddenParam", PagingUtil.getSearchHiddenParam(map));
		
		ReservationDAO dao = sqlSession.getMapper(ReservationDAO.class);
		List<Map<String, Object>> calendarData = dao.selectCalendarData(map);
		
		mv.addAllObjects(map);
		mv.addObject("calendar_data", calendarData);
		
		return mv;
	}
	
	@RequestMapping(value = "annual_management_form.html")
	public ModelAndView formPage(@RequestParam Map<String, Object> map, HttpSession session) throws ParseException {
		ModelAndView mv = TemplateAndPage.getTemplateAndPage(map, TemplateAndPage.PARTIAL_TEMPLATE, VIEW_MAPPING_PATH, "annual_management_form");
		Date date = new Date();
		
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
		if(map.containsKey("select_id")){
			mv.addObject("annual_id", map.get("select_id"));
		}
		mv.addObject("today", sdf.format(date).toString());
		
		Calendar c = Calendar.getInstance();
		c.setTime(sdf.parse(sdf.format(date).toString()));
		c.add(Calendar.DATE, 1); 
		
		mv.addObject("tomorrow", sdf.format(c.getTime()));		
		mv.addObject("proc_id", session.getAttribute(Constants.USER_ID));
		mv.addObject("page_title", "휴가등록");
		return mv;
	}
	
	
	@RequestMapping(value = "annual_select.json")
	public @ResponseBody JsonResultEntity select(HttpSession session, @RequestBody Map<String, Object> map) {
		AnnualMGRDAO dao = sqlSession.getMapper(AnnualMGRDAO.class);
		List<Map<String, Object>> list = dao.selectAnnualListByID(map);	
		
		return reFac.getJsonResultEntity(list);
	}
	
	@RequestMapping(value = "annual_insert.do")
	public @ResponseBody JsonResultEntity insert(HttpSession session, @RequestBody Map<String, Object> map) {
		AnnualMGRDAO dao = sqlSession.getMapper(AnnualMGRDAO.class);
		map.put("proc_id", session.getAttribute(Constants.USER_ID));
		
		try{
			dao.insertAnnual(map);	
		}catch(Exception e){
			logger.error("[ERROR] - Annual Insert Error : " + e.getMessage());
			return reFac.getJsonResultEntityFromResultCd("ERR.COM.0001");
		}
		
		return reFac.getJsonResultEntityFromResultCd("SUC.COM.0001");
	}
	

	@RequestMapping(value = "annual_update.do")
	public @ResponseBody JsonResultEntity update(HttpSession session, @RequestBody Map<String, Object> map) {
		AnnualMGRDAO dao = sqlSession.getMapper(AnnualMGRDAO.class);
		try{
			dao.updateAnnualList(map);	
		}catch(Exception e){
			logger.error(e.getMessage());
		}
		
		return reFac.getJsonResultEntityFromResultCd("SUC.COM.0002");
	}
	
	@RequestMapping(value = "annual_delete.do")
	public @ResponseBody JsonResultEntity delete(HttpSession session, @RequestBody Map<String, Object> map) {
		AnnualMGRDAO dao = sqlSession.getMapper(AnnualMGRDAO.class);
		try{
			dao.deleteAnnualList(map);	
		}catch(Exception e){
			logger.error(e.getMessage());
		}
		
		return reFac.getJsonResultEntityFromResultCd("SUC.COM.0003");
	}
	
	@RequestMapping(value = "annual_permission_chk.do")
	public @ResponseBody JsonResultEntity chkAnnualPermission(HttpSession session, @RequestBody Map<String,Object> map) {
		boolean permission = false;
		String userID = session.getAttribute(Constants.USER_ID).toString();
		if("jswon".equals(userID) || "sgchoi".equals(userID) || "sorry1217".equals(userID) || "admin".equals(userID) || "powe2001".equals(userID)){
			permission = true;
		}
		return reFac.getJsonResultEntity(permission);
	}
	
	@RequestMapping(value = "annual_list.json")
	public @ResponseBody JsonResultEntity getAnnualList(HttpSession session, @RequestBody Map<String,Object> map) {
		AnnualMGRDAO dao = sqlSession.getMapper(AnnualMGRDAO.class);
		map.put("annual_yymm", map.get("year").toString() + "-" + map.get("mon").toString() + "%");
		map.put("annual_last_yymm", map.get("over_year").toString() + "-" + map.get("last_mon").toString() + "%");
		
		List<Map<String, Object>> list = dao.selectAnnualList(map);
		return reFac.getJsonResultEntity(list);
	}
	
	@RequestMapping(value = "annual_list_weekly.json")
	public @ResponseBody JsonResultEntity getAnnualListWeekly(HttpSession session, @RequestBody Map<String,Object> map) {
		AnnualMGRDAO dao = sqlSession.getMapper(AnnualMGRDAO.class);
		List<Map<String, Object>> list = null;
		try{
			list = dao.selectAnnualListWeekly(map);	
		}catch(Exception e){
			logger.error(e.getMessage());
		}
		
		return reFac.getJsonResultEntity(list);
	}
}
