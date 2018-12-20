package com.seculayer.web.tist;

import java.util.ArrayList;
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

import com.seculayer.web.auth.AuthorizationManager;
import com.seculayer.web.common.Config;
import com.seculayer.web.common.util.ConfigurationX;
import com.seculayer.web.common.util.PagingUtil;
import com.seculayer.web.common.util.StringUtil;
import com.seculayer.web.framework.entity.JsonResultEntity;
import com.seculayer.web.framework.entity.ResultEntityFactory;
import com.seculayer.web.framework.util.TemplateAndPage;
import com.seculayer.web.tist.dao.VXShareDAO;


@Controller
@RequestMapping(value = "/tist/")
public class VXShareController {
	
	
	@Autowired private SqlSession sqlSession;
	@Autowired private ResultEntityFactory reFac;
	@Autowired private HttpServletRequest req;
	@Autowired private VXShareService svc;
	
	private static ConfigurationX conf = new ConfigurationX(false);
	
	final static String Menu			= "l_con3";
	final static String Template 	    = "/common/tpl/base_template";
	final static String PopupTemplate 	= "/common/tpl/popup_template";
	final static String VIEW_MAPPING_PATH = "/tist/";
	final static String HOME_PATH = "/Seculayer/app/www_intel/ROOT/WEB-INF/";
	
	final static String UPLOAD_PATH = "tist";
	
	Configuration AdminConfig = Config.getInstance().getConfiguration("AdminConfig");

	static Logger logger = Logger.getLogger(VXShareController.class);

	@RequestMapping(value = "vxshare_list.do")
	public ModelAndView vxshareFileList (@RequestParam Map<String, Object> map, HttpServletRequest req) {
		
		//logger.debug("map :" +map);
		//롤정보 입력
		AuthorizationManager.getInstance(sqlSession).setCommunityRoleList(req,sqlSession);

		String template = StringUtil.isEmpty(map.get("popup")) ? Template : PopupTemplate;	
		ModelAndView mv = new ModelAndView(template);

		String pageId = StringUtil.isEmpty(map.get("page_id")) ? "/tist/vxshare_list" : (String)map.get("page_id");

		mv.addObject("page_title", "VXShare");
		mv.addObject("menu_id", Menu + ".jsp");
		mv.addObject("page_id", pageId + ".jsp");
		
		mv.addObject("searchHiddenParam", PagingUtil.getSearchHiddenParam(map));
		
		VXShareDAO dao = sqlSession.getMapper(VXShareDAO.class);
		
		int listCount = dao.selectVXShareFileCount(map);
		
		PagingUtil.getPagingVXShare(map, listCount, req.getContextPath());
		map.put("startIndex", map.get("startIndex"));
		map.put("endIndex", map.get("pageRow"));
		
		mv.addAllObjects(map);

		List<Map<String,Object>> list = dao.selectVXShareFileList(map);
		List<Map<String,Object>> list_1 = new ArrayList<Map<String, Object>>();
		List<Map<String,Object>> list_2 = new ArrayList<Map<String, Object>>();
		
		int listSize = list.size();
		if(listSize != 0){
			svc.divListData(list, list_1, list_2);
		}
		mv.addObject("list_1", list_1);
		mv.addObject("list_2", list_2);
		
		mv.addObject("listCount", listCount);

		return mv;
	}
	
	@RequestMapping(value = "vxshare_list.json")
	public @ResponseBody JsonResultEntity getList(@RequestBody Map<String,Object> map) {
		VXShareDAO dao = sqlSession.getMapper(VXShareDAO.class);
		int startIndex = 0;
		if(map.get("currPage") != null){
			startIndex = (Integer.parseInt(map.get("currPage").toString())-1) * 20;
			map.put("startIndex", startIndex);
		}
		
		List<Map<String, Object>> list = dao.selectVXShareFileList(map);
		
		List<Map<String,Object>> list_1 = new ArrayList<Map<String, Object>>();
		List<Map<String,Object>> list_2 = new ArrayList<Map<String, Object>>();
		
		int listSize = list.size();
	
		if(listSize != 0){
			svc.divListData(list, list_1, list_2);
		}

		if(Integer.parseInt(map.get("idx").toString()) == 1){
			return reFac.getJsonResultEntity(list_1);	
		}else{
			return reFac.getJsonResultEntity(list_2);	
		}
	}
	
	@RequestMapping(value = "vxshare_detail_view_form.html")
	public ModelAndView vxshareDetailViewForm(@RequestParam Map<String, Object> map) {
		ModelAndView mv = TemplateAndPage.getTemplateAndPage(map, TemplateAndPage.PARTIAL_TEMPLATE, VIEW_MAPPING_PATH, "vxshare_detail_view");
		VXShareDAO dao = sqlSession.getMapper(VXShareDAO.class);
		mv.addObject("page_title", "VXShare Viewer");
		mv.addObject("vxs_file_nm", map.get("vxs_file_nm"));
		
		Map<String, Object> fileMap = dao.getRows(map);
		PagingUtil.getPagingVXShare(map, (int)fileMap.get("rows"), req.getContextPath(),true);
		mv.addAllObjects(map);
		return mv;
	}
	
	@RequestMapping(value = "vxshare_detail_view.json")
	public @ResponseBody JsonResultEntity getVXShareData(@RequestBody Map<String,Object> map) {
		VXShareDAO dao = sqlSession.getMapper(VXShareDAO.class);
		List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
		
		int pageUnit = 15;
		List<Map<String, Object>> fileList = dao.selectVXShareFileAllList(map);
		
		int selectFileIndex = 0;
		for(int i=0; i<fileList.size(); i++){
			if(map.get("vxs_file_nm").equals(fileList.get(i).get("file_nm"))){
				selectFileIndex = i;
			}
		}
		
		int rowStartIndex = 0;
		
		for(int i=0; i<selectFileIndex; i++){
			rowStartIndex += (int)fileList.get(i).get("rows");
		}

		int startIndex = rowStartIndex + (Integer.parseInt(map.get("currPageViewer").toString())-1) * pageUnit + 1;
		int dataRows = (int)fileList.get(selectFileIndex).get("rows");

		if((startIndex + pageUnit) > rowStartIndex + dataRows){
			for(int i=startIndex; i<=rowStartIndex + dataRows; i++){
				map.put("seq", i);
				Map<String, Object> data = dao.selectVXShareDataBySeq(map);
				list.add(data);
			}
		}else{
			for(int i=startIndex; i<=startIndex + pageUnit-1; i++){
				map.put("seq", i);
				Map<String, Object> data = dao.selectVXShareDataBySeq(map);
				list.add(data);
			}
		}
		return reFac.getJsonResultEntity(list);	
	}
}
