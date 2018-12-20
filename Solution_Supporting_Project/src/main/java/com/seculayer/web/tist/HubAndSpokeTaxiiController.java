package com.seculayer.web.tist;

import java.net.UnknownHostException;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

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

import com.seculayer.web.common.Config;
import com.seculayer.web.common.util.StringUtil;
import com.seculayer.web.framework.entity.JsonResultEntity;
import com.seculayer.web.framework.entity.ResultEntityFactory;
import com.seculayer.web.tist.dao.HubAndSpokeTaxiiDAO;

@Controller
@RequestMapping(value = "/tist/")
public class HubAndSpokeTaxiiController {
	
	
	@Autowired private SqlSession sqlSession;
	@Autowired private ResultEntityFactory reFac;
	@Autowired private HubAndSpokeTaxiiService svc = new HubAndSpokeTaxiiService();
	
	final static String Menu			= "l_con3";
	final static String Template 	    = "/common/tpl/base_template";
	final static String PopupTemplate 	= "/common/tpl/popup_template";
	final static String VIEW_MAPPING_PATH = "/tist/";
	final static String HOME_PATH = "/Seculayer/app/www_intel/ROOT/WEB-INF/";
	
	final static String UPLOAD_PATH = "tist";
	
	Configuration AdminConfig = Config.getInstance().getConfiguration("AdminConfig");

	static Logger logger = Logger.getLogger(HubAndSpokeTaxiiController.class);

	@RequestMapping(value = "hub_spoke_taxii.do")
	public ModelAndView listPage(HttpServletRequest req, @RequestParam Map<String, Object> map) {
		String template = StringUtil.isEmpty(map.get("popup")) ? Template : PopupTemplate;	
		ModelAndView mv = new ModelAndView(template);
		String pageId = StringUtil.isEmpty(map.get("page_id")) ? "/tist/hub_spoke_taxii" : (String)map.get("page_id");
		mv.addObject("menu_id", Menu + ".jsp");
		mv.addObject("page_id", pageId + ".jsp");
		
		return mv;
	}
	
	@RequestMapping(value = "hub_spoke_taxii_server_info.json")
	public @ResponseBody JsonResultEntity getList(@RequestBody Map<String,Object> map) throws UnknownHostException {
		HubAndSpokeTaxiiDAO dao = sqlSession.getMapper(HubAndSpokeTaxiiDAO.class);
		int check = dao.checkServerInfo();
		if(check == 0){
			svc.initServerInfo();
		}else{
			svc.updateServerInfo();
		}
		Map<String, Object> list = dao.selectServerInfo();
		
		return reFac.getJsonResultEntity(list);	
	}
	
	@RequestMapping(value = "hub_spoke_taxii_server_info_type.json")
	public @ResponseBody JsonResultEntity getServerListByType(@RequestBody Map<String,Object> map) throws UnknownHostException {
		HubAndSpokeTaxiiDAO dao = sqlSession.getMapper(HubAndSpokeTaxiiDAO.class);
		List<Map<String, Object>> list = dao.selectServerInfoByType(map);
		
		return reFac.getJsonResultEntity(list);	
	}
	
	@RequestMapping(value = "hub_spoke_taxii_threat_server_info.json")
	public @ResponseBody JsonResultEntity getThreatServerList(@RequestBody Map<String,Object> map) throws UnknownHostException {
		HubAndSpokeTaxiiDAO dao = sqlSession.getMapper(HubAndSpokeTaxiiDAO.class);
		List<Map<String, Object>> list = dao.selectThreatServerInfo(map);
		
		return reFac.getJsonResultEntity(list);	
	}
	
	@RequestMapping(value = "hub_spoke_taxii_threat_server_info_update.do")
	public @ResponseBody JsonResultEntity updateThreatServerList(@RequestBody Map<String,Object> map) throws UnknownHostException {
		HubAndSpokeTaxiiDAO dao = sqlSession.getMapper(HubAndSpokeTaxiiDAO.class);
		int result = 0;
		try{
			dao.updateThreatServerInfo(map);
		}catch(Exception e){
			result = -1;
		}
		return reFac.getJsonResultEntity(result);	
	}
	
	@RequestMapping(value = "hub_spoke_taxii_threat_server_info_delete.do")
	public @ResponseBody JsonResultEntity deleteThreatServerList(@RequestBody Map<String,Object> map) throws UnknownHostException {
		HubAndSpokeTaxiiDAO dao = sqlSession.getMapper(HubAndSpokeTaxiiDAO.class);
		int result = 0;
		try{
			dao.deleteThreatServerInfo(map);
		}catch(Exception e){
			result = -1;
		}
		return reFac.getJsonResultEntity(result);	
	}
	
	@RequestMapping(value = "hub_spoke_taxii_server_status.json")
	public @ResponseBody JsonResultEntity getStatusList(@RequestBody Map<String,Object> map) {
		Map<String, String> statusMap = svc.getStatus();
		return reFac.getJsonResultEntity(statusMap);	
	}
	
	@RequestMapping(value = "hub_spoke_taxii_threat_server_insert.do")
	public @ResponseBody JsonResultEntity insertThreatSharingServer(@RequestBody Map<String,Object> map) throws UnknownHostException {
		HubAndSpokeTaxiiDAO dao = sqlSession.getMapper(HubAndSpokeTaxiiDAO.class);
		int result = 0;
		try{
			dao.insertThreatSharingServer(map);
		}catch(Exception e){
			result = -1;
		}
		return reFac.getJsonResultEntity(result);	
	}
	
}
