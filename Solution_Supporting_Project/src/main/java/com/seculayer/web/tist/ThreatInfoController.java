package com.seculayer.web.tist;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
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
import com.seculayer.web.common.util.PagingUtil;
import com.seculayer.web.common.util.Path;
import com.seculayer.web.common.util.StringUtil;
import com.seculayer.web.framework.entity.JsonResultEntity;
import com.seculayer.web.framework.entity.ResultEntityFactory;
import com.seculayer.web.framework.util.TemplateAndPage;
import com.seculayer.web.tist.dao.ThreatInfoDAO;


@Controller
@RequestMapping(value = "/tist/")
public class ThreatInfoController {
	
	
	@Autowired private SqlSession sqlSession;
	@Autowired private ResultEntityFactory reFac;
	@Autowired private HttpServletRequest req;
	@Autowired private ThreatInfoService svc;
	
	private static ConfigurationX conf = new ConfigurationX(false);
	
	final static String Menu			= "l_con3";
	final static String Template 	    = "/common/tpl/base_template";
	final static String PopupTemplate 	= "/common/tpl/popup_template";
	final static String VIEW_MAPPING_PATH = "/tist/";
	final static String HOME_PATH = "/Seculayer/app/www_intel/ROOT/WEB-INF/";
//	final static String HOME_PATH = "C:/Users/HJ/Desktop/Workspace/00.[src_workspace]/401.[Intelligence_Center]/src/main/webapp/WEB-INF";
	
	final static String UPLOAD_PATH = "tist";
	
	Configuration AdminConfig = Config.getInstance().getConfiguration("AdminConfig");

	static Logger logger = Logger.getLogger(ThreatInfoController.class);

	private String taxiiPullCont = "";
	
	@RequestMapping(value = "taxii_server_list.html")
	public ModelAndView listPage(HttpServletRequest req, @RequestParam Map<String, Object> map) {
		
		ModelAndView mv = TemplateAndPage.getTemplateAndPage(map, "div", VIEW_MAPPING_PATH, "taxii_server_list", new Object[][] {
			{"STIX 생성","btnTIGenerator"},
		});
		
		
		/*mv.addObject("parserInfoUrl", "/ParserHandlerServlet?action_code=-1");
		mv.addObject("indexInfoUrl", "/index_list");*/

		return mv;
	}
	
	@RequestMapping(value = "taxii_server_list.do")
	public ModelAndView taxiiServerList (@RequestParam Map<String, Object> map, HttpServletRequest req) {
		AuthorizationManager.getInstance(sqlSession).setCommunityRoleList(req,sqlSession);

		ModelAndView mv = TemplateAndPage.getTemplateAndPage(map, "div", VIEW_MAPPING_PATH, "taxii_server_list");
		
		mv.addObject("menu_id", Menu + ".jsp");
		mv.addObject("searchHiddenParam", PagingUtil.getSearchHiddenParam(map));
		
		ThreatInfoDAO dao = sqlSession.getMapper(ThreatInfoDAO.class);
	
		int listCount = dao.selectServerListCount(map);
		
		PagingUtil.getPagingTaxii(map, listCount, req.getContextPath());
		Long pageRow = StringUtil.getLong(StringUtil.isEmpty(map.get("pageRow")) ? 10 : map.get("pageRow"));
		map.put("sttIndex", 0);
		map.put("pageRow", pageRow);
		
		mv.addAllObjects(map);
		mv.addObject("listCount", listCount);
		
		return mv;
	}
	
	@RequestMapping(value = "taxii_server_list.json")
	public @ResponseBody JsonResultEntity getList(@RequestBody Map<String,Object> map) {
		
		ThreatInfoDAO dao = sqlSession.getMapper(ThreatInfoDAO.class);
		Integer listCount = dao.selectServerListCount(map);
		List<Map<String, Object>> list = Collections.emptyList();

		if(map.containsKey("currPage") && map.containsKey("pageRows")){
			int currPage = Integer.parseInt(map.get("currPage").toString());
			int pageRows = Integer.parseInt(map.get("pageRows").toString());
			int startIndex = (currPage - 1) * pageRows;
			
			map.put("startIndex", startIndex);		
			map.put("endIndex", startIndex + pageRows);		
		}

		if (listCount > 0) {
			list = dao.selectServerList(map);
		}
		return reFac.getJsonResultEntity(list);
	}
	
	@RequestMapping(value = "taxii_server.json")
	public @ResponseBody JsonResultEntity get(@RequestBody Map<String, Object> map) {
		return reFac.getJsonResultEntity(svc.select(map));
	}
	
	@RequestMapping(value = "taxii_server_form.html")
	public ModelAndView formPage(@RequestParam Map<String, Object> map) {
		ModelAndView mv = TemplateAndPage.getTemplateAndPage(map, TemplateAndPage.PARTIAL_TEMPLATE, VIEW_MAPPING_PATH, "taxii_server_form");
		mv.addObject("page_title", "TAXII Server 등록");
		return mv;
	}
	
	@RequestMapping(value = "stix_generator_form.html")
	public ModelAndView stixGenFormPage(@RequestParam Map<String, Object> map) {
		ModelAndView mv = TemplateAndPage.getTemplateAndPage(map, TemplateAndPage.PARTIAL_TEMPLATE, VIEW_MAPPING_PATH, "stix_generator_form");
		mv.addObject("page_title", "STIX Template 생성");
		return mv;
	}
	
	@RequestMapping(value = "stix_parsing_form.html")
	public ModelAndView stixParsingFormPage(@RequestParam Map<String, Object> map) {
		ModelAndView mv = TemplateAndPage.getTemplateAndPage(map, TemplateAndPage.PARTIAL_TEMPLATE, VIEW_MAPPING_PATH, "stix_parsing_form");
		mv.addObject("page_title", "STIX Parsing");
		return mv;
	}
	
	@RequestMapping(value = "taxii_pull_form.html")
	public ModelAndView taxiiPullFormPage(@RequestParam Map<String, Object> map) {
		ModelAndView mv = TemplateAndPage.getTemplateAndPage(map, TemplateAndPage.PARTIAL_TEMPLATE, VIEW_MAPPING_PATH, "taxii_pull_form");
		mv.addObject("page_title", "Taxii Pull Service");
		return mv;
	}
	
	@RequestMapping(value = "taxii_server_check_ip.json")
	public @ResponseBody JsonResultEntity serverCheckIP(@RequestBody Map<String, Object> map) {
		ThreatInfoDAO dao = sqlSession.getMapper(ThreatInfoDAO.class);
		int checkCount = dao.checkServerIP(map);
		
		return reFac.getJsonResultEntity(checkCount == 0);
	}
	
	@RequestMapping(value = "taxii_server_check_id.json")
	public @ResponseBody JsonResultEntity serverCheckID(@RequestBody Map<String, Object> map) {
		ThreatInfoDAO dao = sqlSession.getMapper(ThreatInfoDAO.class);
		int checkCount = dao.checkServerID(map);
		
		return reFac.getJsonResultEntity(checkCount == 0);
	}
	
	@RequestMapping(value = "taxii_server_insert.do")
	public @ResponseBody JsonResultEntity insert(HttpSession session, @RequestBody Map<String, Object> map) {
		map.put("proc_id", session.getAttribute(Constants.USER_ID));
		map.put("proc_ip", req.getRemoteAddr());
		try{
			svc.insert(map);
		}catch(Exception e){
			return reFac.getJsonResultEntityFromResultCd("ERR.COM.0001");
		}
		
			
		return reFac.getJsonResultEntityFromResultCd("SUC.COM.0001");
	}
	
	@RequestMapping(value = "taxii_server_update.do")
	public @ResponseBody JsonResultEntity update(HttpSession session, @RequestBody Map<String, Object> map) {
		map.put("proc_id", session.getAttribute(Constants.USER_ID));
		map.put("proc_ip", req.getRemoteAddr());
		svc.update(map);

		return reFac.getJsonResultEntityFromResultCd("SUC.COM.0002");
	}
	
	@RequestMapping(value = "taxii_server_delete.do")
	public @ResponseBody JsonResultEntity delete(HttpSession session, @RequestBody Map<String, Object> map) {
		svc.delete(map);

		return reFac.getJsonResultEntityFromResultCd("SUC.COM.0003");
	}
	
	@RequestMapping(value = "taxii_pull_service.json")
	public @ResponseBody JsonResultEntity taxiiPullService(@RequestBody Map<String, Object> map) throws MalformedURLException, JAXBException, IOException, URISyntaxException, Exception {
		ArrayList<Object> result = null;
		try{
			 result = svc.taxiiSvcPull(map);	
		}catch(Exception e){
			result.add(-1);
			result.add(e.getMessage());
			
			return reFac.getJsonResultEntity(result);
		}
		
		return reFac.getJsonResultEntity(result);
	}
	
	@RequestMapping(value = "taxii_pull_cont_view.html")
	public ModelAndView taxiiPullViewForm(@RequestParam Map<String, Object> map) {
		ModelAndView mv = TemplateAndPage.getTemplateAndPage(map, TemplateAndPage.PARTIAL_TEMPLATE, VIEW_MAPPING_PATH, "taxii_pull_detail_form");
		mv.addObject("page_title", "Taxii Pull Result");
		mv.addObject("cont", taxiiPullCont);
		return mv;
	}
	
	@RequestMapping(value = "taxii_pull_set_cont.do")
	public @ResponseBody JsonResultEntity setTaxiiPullView(@RequestBody Map<String, Object> map) {
		taxiiPullCont = map.get("cont").toString().trim();
		return reFac.getJsonResultEntity(true);
	}
	
	@RequestMapping(value = "stix_generator.do")
	public @ResponseBody JsonResultEntity generatorSTIX(@RequestBody Map<String, Object> map) throws SAXException {
		try{
			File confDir = new File(HOME_PATH, "conf");
			File configFile = new File(confDir, "ti_conf.xml");
			conf.addResource(new Path(configFile.getAbsolutePath()));
			
			BufferedWriter out = new BufferedWriter(new FileWriter(conf.get("stix.gen.path") + "/" + map.get("file_nm") + ".stix"));
			String s = map.get("stix_print").toString();	

			out.write(s);
			out.close();
		      
		}catch(Exception e){
			return reFac.getJsonResultEntity(false);
		}
		
		return reFac.getJsonResultEntity(true);
	}
	
	@RequestMapping(value = "taxii_pull_stix_gen.do")
	public @ResponseBody JsonResultEntity generatorPullSTIX(@RequestBody Map<String, Object> map) throws SAXException {
		try{
			File confDir = new File(HOME_PATH, "conf");
			File configFile = new File(confDir, "ti_conf.xml");
			conf.addResource(new Path(configFile.getAbsolutePath()));
			
			//현재시간 파일명 / 디비 저장 / 디비 정보 추출
			BufferedWriter out = new BufferedWriter(new FileWriter(conf.get("taxii.pull.stix.gen.path") + "/" + map.get("stixSaveName")+ ".stix"));
			String s = taxiiPullCont;

			out.write(s);
			out.close();
		      
		}catch(Exception e){
			return reFac.getJsonResultEntity(false);
		}
		
		return reFac.getJsonResultEntity(true);
	}
	
	@RequestMapping(value = "stix_template.json")
	public @ResponseBody JsonResultEntity generatorSTIXTpl(@RequestBody Map<String, Object> map) throws SAXException {
		String result = "";
		try{
			result = svc.genSTIXTpl(map);
		}catch(Exception e){
			return reFac.getJsonResultEntity(result);
		}
		
		return reFac.getJsonResultEntity(result);
	}
	
	@RequestMapping(value = "stix_parsing.json")
	public @ResponseBody JsonResultEntity parsingSTIX(@RequestBody Map<String, Object> map) throws SAXException {
		ArrayList<Object> result = null;
		try{
			result = svc.getSTIXParsing(map);
		}catch(Exception e){
			return reFac.getJsonResultEntity(result);
		}
		
		return reFac.getJsonResultEntity(result);
	}
	
}
