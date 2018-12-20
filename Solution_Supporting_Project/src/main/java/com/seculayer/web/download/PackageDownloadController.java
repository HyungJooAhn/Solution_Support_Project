package com.seculayer.web.download;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.commons.compress.archivers.zip.ZipArchiveEntry;
import org.apache.commons.compress.archivers.zip.ZipArchiveOutputStream;
import org.apache.commons.configuration.Configuration;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.ibatis.session.SqlSession;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.seculayer.web.common.ComCode;
import com.seculayer.web.common.Config;
import com.seculayer.web.common.Constants;
import com.seculayer.web.common.util.FileUtil;
import com.seculayer.web.common.util.PagingUtil;
import com.seculayer.web.common.util.StringUtil;
import com.seculayer.web.download.dao.PackageDownloadDAO;
import com.seculayer.web.framework.entity.JsonResultEntity;
import com.seculayer.web.framework.entity.ResultEntityFactory;
import com.seculayer.web.framework.util.TemplateAndPage;

@Controller
@RequestMapping(value = "/download/")
public class PackageDownloadController {

	static Logger logger = Logger.getLogger(PackageDownloadController.class);

	Configuration AdminConfig = Config.getInstance().getConfiguration("AdminConfig");

	@Autowired
	private SqlSession sqlSession;
	@Autowired
	private ComCode comCode;
	@Autowired
	private HttpServletRequest req;
	@Autowired
	private ResultEntityFactory reFac;
	
	final static String Menu = "l_con6";
	final static String Template = "/common/tpl/base_template";
	final static String VIEW_MAPPING_PATH = "/download/";
	// final static String PopupTemplate = "/common/tpl/popup_template";

	@RequestMapping(value = "download_menu_list.do")
	public ModelAndView downloadFileList(HttpSession session, @RequestParam Map<String, Object> map) throws Exception {
		
		PackageDownloadDAO dao = sqlSession.getMapper(PackageDownloadDAO.class);
		String userId = (String) session.getAttribute(Constants.USER_ID);
		int userRoleId = dao.selectComUserRole(userId);
		if (!map.containsKey("major_version") || !map.containsKey("file_type")) {
			if(userRoleId == 2 || userRoleId == 7) map.put("major_version", "3.0");
			else map.put("major_version", "3.1");
			map.put("file_type", "all-in-one");
			map.put("product_code", 7);
		} else if(StringUtil.get(map.get("major_version")).equals("3.1") && (userRoleId == 2 || userRoleId == 7)) {
			map.put("major_version", "3.0");
		}
		
		ObjectMapper mapper = new ObjectMapper();

		List<Map<String, Object>> fileList = dao.selectDownloadList(map);
		ModelAndView mv = new ModelAndView(Template);

		String pageId = StringUtil.isEmpty(map.get("page_id")) ? "/download/download_list"
				: (String) map.get("page_id");

		mv.addObject("page_title", "다운로드");
		mv.addObject("menu_id", Menu + ".jsp");
		mv.addObject("page_id", pageId + ".jsp");
		mv.addObject("file_list", fileList);
		mv.addObject("fileListJson", mapper.writeValueAsString(fileList));
		mv.addObject("file_type", map.get("file_type"));
		mv.addObject("major_version", map.get("major_version"));
		mv.addObject("product_code", map.get("product_code"));
		//mv.addObject("file_category", map.get("file_version").toString().replaceAll("%", ""));
		mv.addObject("user_id", userId);
		
		return mv;
	}

	@RequestMapping(value = "download_patch_detail_view.do")
	public ModelAndView downloadPatchDetailView(HttpSession session, @RequestParam Map<String, Object> map) {
		PackageDownloadDAO dao = sqlSession.getMapper(PackageDownloadDAO.class);
		Map<String, Object> detailFileInfo = dao.selectDownloadPatchDetail(map);

		ModelAndView mv = new ModelAndView(Template);

		String pageId = StringUtil.isEmpty(map.get("page_id")) ? "/download/download_patch_detail_view"
				: (String) map.get("page_id");

		String userId = (String) session.getAttribute(Constants.USER_ID);
		Map<String, Object> userInfo = (Map<String, Object>) session.getAttribute(Constants.USER_SESSION);
		mv.addObject("page_title", "다운로드");
		mv.addObject("menu_id", Menu + ".jsp");
		mv.addObject("page_id", pageId + ".jsp");
		mv.addObject("detailFileInfo", detailFileInfo);
		map.put("p_user_id", userId);
		map.put("role_id", userInfo.get("role_id"));

		return mv;
	}

	@RequestMapping(value = "file_delete.do")
	public ModelAndView downloadFileDelete(HttpSession session, @RequestParam Map<String, Object> map) {
		PackageDownloadDAO dao = sqlSession.getMapper(PackageDownloadDAO.class);
		String product_code = StringUtil.get(map.get("product_code"));
		String major_version = StringUtil.get(map.get("major_version"));
		String file_type = StringUtil.get(map.get("file_type"));
		List<Map<String, Object>> delfileList = dao.selectDelFileInfo(map);
		String url = "redirect:/download/download_menu_list.do?major_version=" + major_version + "&file_type="
				+ file_type+ "&product_code="+ product_code;
		ModelAndView mv = new ModelAndView(url);
		
		String basicPath = AdminConfig.getString("upload_path");

		for(int i=0;i<delfileList.size();i++){
			Map<String, Object> delFileInfo = delfileList.get(i);
			String del_file_name = (String) delFileInfo.get("file_nm");
			String delPath = basicPath +delFileInfo.get("file_type")+"/"+delFileInfo.get("product_code")+"/"+ delFileInfo.get("major_version") + "/" + delFileInfo.get("minor_version") + "/"+del_file_name;
			// 디렉토리 선택
			File selectedDir = new File(delPath);
			mv.addObject("delFileResult"+i,selectedDir.delete()) ;
		}
		
		int delResult = dao.downloadMenufileDelete(map);
		mv.addObject("delResultQuery", delResult);
		
		
		return mv;
	}
	
	@RequestMapping(value = "file_down_cntup.do")
	public ModelAndView fileDownloadCountUp(HttpSession session, @RequestParam Map<String, Object> map) {
		PackageDownloadDAO dao = sqlSession.getMapper(PackageDownloadDAO.class);
		Map<String,Object> data = dao.selectDownloadPatchDetail(map);

		File file = new File(data.get("file_path").toString()+ data.get("file_nm"));
		
		int cntUpResult = dao.downloadCntUp(map);
				
		ModelAndView mv = new ModelAndView("download", "file", file);
		mv.addObject("cntUpResult", cntUpResult);
		return mv;
	}

	@RequestMapping(value = "file_upload_form.do")
	public ModelAndView uploadform(@RequestParam Map<String, Object> map) {

		PackageDownloadDAO dao = sqlSession.getMapper(PackageDownloadDAO.class);

		String pageId = StringUtil.isEmpty(map.get("page_id")) ? "/download/file_upload_form"
				: (String) map.get("page_id");

		ModelAndView mv = new ModelAndView(Template);
		if (map.containsKey("file_id")) {
			if (!map.get("file_id").toString().equals("")) {
				Map<String, Object> detailFileInfo = dao.selectDownloadPatchDetail(map);
				mv.addObject("detailFileInfo", detailFileInfo);

			}
		}
		mv.addObject("page_title", "파일 관리");
		mv.addObject("menu_id", Menu + ".jsp");
		mv.addObject("page_id", pageId + ".jsp");
		mv.addObject("major_version", map.get("major_version"));
		mv.addObject("product_code", map.get("product_code"));
		mv.addObject("file_type", map.get("file_type"));
/*		mv.addObject("file_category", map.get("file_category").toString().replaceAll("%", ""));*/
		mv.addObject("searchHiddenParam", PagingUtil.getSearchHiddenParam(map));
		return mv;
	}

	@RequestMapping(value = "file_type_check.do")
	public @ResponseBody String check(@RequestParam Map<String, Object> map) {
		PackageDownloadDAO dao = sqlSession.getMapper(PackageDownloadDAO.class);
		String file_name = (String) map.get("file_name");
		file_name = file_name.split("\\\\")[(file_name.split("\\\\").length - 1)];
		map.put("file_name", file_name);
		List<Map<String, Object>> checkResult = dao.checkExistenceFile(map);
		if (checkResult.size() < 1)
			return "OK";
		else
			return "EXIST";
	}

	@Transactional(rollbackFor = Exception.class)
	@RequestMapping(value = "file_add.do")
	public ModelAndView uploadFile(HttpSession session, @RequestParam("file_name") MultipartFile[] file,
			@RequestParam Map<String, Object> map) throws Exception {
		PackageDownloadDAO dao = sqlSession.getMapper(PackageDownloadDAO.class);

		String fileType = StringUtil.get(map.get("file_type"));
		String file_version = "v"+(String) map.get("major_version") +"_"+ (String) map.get("minor_version");

		map.put("proc_id", session.getAttribute(Constants.USER_ID));
		map.put("proc_ip", req.getRemoteAddr());
		map.put("file_version", file_version);
		map.put("use_yn", "N");

		if (!map.containsKey("comments")) {
			map.put("comments", "");
		}
		String basicPath = AdminConfig.getString("upload_path");
		String file_path = basicPath + fileType+ "/" + map.get("product_code") + "/" + map.get("major_version") + "/" + map.get("minor_version") + "/";
		
		map.put("file_path", file_path);
		List<Map<String, Object>> fileList = new ArrayList<Map<String, Object>>();
		Map<String, Object> fileData;

		for (int i = 0; file != null && i < file.length; i++) {
			if (!file[i].isEmpty()) {
				map.put("file_nm", file[i].getOriginalFilename());
				fileData = saveFile(session, file[i], file_path);
				map.put("md5", fileData.get("md5"));
				map.put("file_size", fileData.get("file_size"));
				fileList.add(fileData);
			}
		}
		
		//int insertResult = dao.insertFileData(map);
		dao.insertFileData(map);

		ModelAndView mv = new ModelAndView("redirect:/download/download_menu_list.do?"
				+ "file_type=" + fileType + "&"
				+ "major_version=" + map.get("major_version") + "&"
				+ "product_code="+map.get("product_code"));
		
		mv.addAllObjects(PagingUtil.getSearchHiddenParamMap(map));

		return mv;
	}
	
	@RequestMapping(value = "package_download_onoff.json")
	public @ResponseBody Map<String,Object> updateUseYn(HttpSession session, @RequestBody List<Map<String, Object>> list) {
		
		PackageDownloadDAO dao = sqlSession.getMapper(PackageDownloadDAO.class);
		
		for(Map<String,Object> map : list) {
			dao.updateDownloadUseYn(map);
		}
		
		Map<String,Object> rsMap = new HashMap<String,Object>();
		rsMap.put("RESULT_CODE", "0000");
		rsMap.put("RESULT_MSG", "Success");

		return rsMap;
	}
/*
	@Transactional(rollbackFor = Exception.class)
	@RequestMapping(value = "file_update.do")
	public ModelAndView updateFile(HttpSession session, @RequestParam("file_name") MultipartFile[] file,
			@RequestParam Map<String, Object> map) throws Exception {
		PackageDownloadDAO dao = sqlSession.getMapper(PackageDownloadDAO.class);

		String fileType = StringUtil.get(map.get("file_type"));
		String file_version = (String) map.get("file_version1") + (String) map.get("file_version2");
		Map<String, Object> fileData;
		int updateResult;
		ModelAndView mv;

		map.put("proc_id", session.getAttribute(Constants.USER_ID));
		map.put("proc_ip", req.getRemoteAddr());
		map.put("file_path", basicPath);
		map.put("file_version", file_version);

		if (!map.containsKey("comments")) {
			map.put("comments", "");
		}

		String file_path = basicPath + file_version + "/" + fileType + "/";
		List<Map<String, Object>> fileList = new ArrayList<Map<String, Object>>();
		// 기존파일 그대로 사용
		if (file[0].isEmpty()) {
			map.put("updateFileFlag", "useOld");
			updateResult = dao.updateFile(map);
		} else {
			String del_file_name = (String) map.get("pre_file_name");
			String del_file_path = basicPath + map.get("pre_file_version") + "/" + fileType + "/"+del_file_name;
			map.put("updateFileFlag", "useNew");
			// 디렉토리 선택
			File selectedDir = new File(del_file_path);
			selectedDir.delete();
			//파일 생성
			for (int i = 0; file != null && i < file.length; i++) {
				if (!file[i].isEmpty()) {
					map.put("file_name", file[i].getOriginalFilename());
					fileData = saveFile(session, file[i], file_path);
					map.put("md5", fileData.get("md5"));
					fileList.add(fileData);
				}
			}
			updateResult = dao.updateFile(map);

		}
		mv = new ModelAndView("redirect:/download/download_menu_list.do?file_type=" + fileType + "&" + "file_version="
				+ (String) map.get("file_version1"));
		mv.addAllObjects(PagingUtil.getSearchHiddenParamMap(map));

		return mv;
	}
*/

	private Map<String, Object> saveFile(HttpSession session, MultipartFile file, String savePath) throws IOException {
		Map<String, Object> map = null;
		String filePath, orgFileName;

		if (!file.isEmpty()) {
			filePath = savePath;

			File dir = new File(filePath);
			// 폴더없으면 만들어줌
			if (!dir.exists())
				FileUtils.forceMkdir(dir);

			// 파일오리지날이름
			orgFileName = file.getOriginalFilename();
			
			File saveFile = new File(dir, orgFileName);

			file.transferTo(saveFile);

			map = new HashMap<String, Object>();
			map.put("file_nm", orgFileName);
			map.put("file_size", file.getSize());
			map.put("md5", FileUtil.md5Hex(saveFile));
		}

		return map;
	}

	@RequestMapping(value = "patch_file_management.do")
	public ModelAndView patchFileManagement(HttpSession session, @RequestParam Map<String, Object> map) {
		PackageDownloadDAO dao = sqlSession.getMapper(PackageDownloadDAO.class);

		ModelAndView mv = new ModelAndView(Template);
		String pageId = StringUtil.isEmpty(map.get("page_id")) ? "/download/patch_file_management" : (String)map.get("page_id");

		int listCount = dao.patchFileListCount(map);
		PagingUtil.getPaging(map, listCount, req.getContextPath());
		
		mv.addAllObjects(map);
		
		List<Map<String, Object>> list = dao.patchFileList(map);
		mv.addObject("menu_id", Menu + ".jsp");
		mv.addObject("page_id", pageId + ".jsp");
		mv.addObject("list", list);
		
		return mv;
	}
	
	@RequestMapping(value = "patch_file_form.html")
	public ModelAndView formPage(@RequestParam Map<String, Object> map) {
		ModelAndView mv = TemplateAndPage.getTemplateAndPage(map, TemplateAndPage.PARTIAL_TEMPLATE, VIEW_MAPPING_PATH, "patch_file_form");
		
		Date now = new Date();
	    SimpleDateFormat date = new SimpleDateFormat("yyyyMMddHHmmss");
		String uploadFolderPath = AdminConfig.getString("upload_path") + "patch_gen/" + date.format(now);
		
		mv.addObject("page_title", "패치파일 생성");
		mv.addObject("file_upload_path", uploadFolderPath);
		return mv;
	}
	
	@RequestMapping(value = "patch_folder_add.do")
	public @ResponseBody JsonResultEntity patchFolderAdd(@RequestBody Map<String, Object> map) {
		boolean result = true;
	    try{
	    	File uploadFolderPath = new File(map.get("path").toString());
			if(!uploadFolderPath.exists()){
				uploadFolderPath.mkdirs();
			}	
	    }catch(Exception e){
	    	logger.error("[ERROR] - Folder Create Error : " + e.getMessage());
	    	result = false;
	    }
		return reFac.getJsonResultEntity(result);
	}
	
	@RequestMapping(value = "patch_folder_remove.do")
	public @ResponseBody JsonResultEntity patchFolderRemove(@RequestBody Map<String, Object> map) {
		boolean result = true;
	    
	    try{
	    	File uploadFolderPath = new File(map.get("path").toString());
	    	if(uploadFolderPath.exists()){
	    		if(uploadFolderPath.isDirectory()){
		    		removeDirectory(uploadFolderPath.getAbsolutePath());
		    	}else{
		    		uploadFolderPath.delete();
				}		    		
	    	}
	    }catch(Exception e){
	    	logger.error("[ERROR] - Folder Delete Error : " + e.getMessage());
	    	result = false;
	    }
		return reFac.getJsonResultEntity(result);
	}
	
	@RequestMapping(value = "patch_file_name_dup.do")
	public @ResponseBody JsonResultEntity patchFileNameDupCheck(@RequestBody Map<String, Object> map) {
		PackageDownloadDAO dao = sqlSession.getMapper(PackageDownloadDAO.class);
	    int result = dao.patchFileNameDupCheck(map);
	    
		return reFac.getJsonResultEntity(result);
	}
	
	@RequestMapping(value = "patch_file_upload.do")
	public @ResponseBody JsonResultEntity patchFileUpload(@RequestParam(value = "drop_file_upload_files") MultipartFile[] uploadFiles,
			@RequestParam(value = "drop_file_upload_pathes") String[] uploadPathes) {
		boolean result = true;
		try{
			for(int i=0; i<uploadFiles.length; i++){
				File file = new File(uploadPathes[i]);
				uploadFiles[i].transferTo(file);
			}
			
		}catch(Exception e){
			logger.error("[ERROR] - File Upload Error : " + e.getMessage());
			result = false;
		}
		return reFac.getJsonResultEntity(result);
	}
	
	@RequestMapping(value = "patch_file_md5.do")
	public @ResponseBody JsonResultEntity getPatchFileMD5(@RequestBody Map<String, Object> map) {
		File file = new File(map.get("upload_path").toString());
		String md5 = FileUtil.md5Hex(file);
		return reFac.getJsonResultEntity(md5);
	}
	
	@RequestMapping(value = "patch_file_download.do")
	public ModelAndView patchFileDownload(@RequestParam Map<String, Object> map) {
		PackageDownloadDAO dao = sqlSession.getMapper(PackageDownloadDAO.class);
		
		Map<String,Object> fileInfo = dao.selectFileInfoByID(map);
		File file = new File(fileInfo.get("file_path").toString());
		
		ModelAndView mv = new ModelAndView("download", "file", file);
		return mv;
	}
	
	@RequestMapping(value = "patch_file_delete.do")
	public @ResponseBody JsonResultEntity patchFileDelete(@RequestBody Map<String, Object> map) {
		PackageDownloadDAO dao = sqlSession.getMapper(PackageDownloadDAO.class);
		boolean result = true;
		try{
			Map<String,Object> fileInfo = dao.selectFileInfoByID(map);
			File file = new File(fileInfo.get("file_path").toString());
			file.delete();
			dao.patchFileDelete(map);
			
		}catch(Exception e){
			logger.info("[ERROR] - Patch File Delete Error : " + e.getMessage());
			result = false;
		}
		return reFac.getJsonResultEntity(result);
	}
	
	@RequestMapping(value = "patch_file_generate.do")
	public @ResponseBody JsonResultEntity patchFileGenerate(@RequestParam(value = "file_upload_path") String uploadPath,
			@RequestParam(value = "file_name") String fileName,
			@RequestParam(value = "sql_list") String sqlListStr,
			@RequestParam(value = "lib_patch_map") String libPatchMapStr,
			@RequestParam(value = "proc_list") String procListStr,
			@RequestParam(value = "patch_cont") String patchCont,
			HttpSession session) throws IOException{
		boolean result = true;
		
		PackageDownloadDAO dao = sqlSession.getMapper(PackageDownloadDAO.class);
		Map<String, Object> param = new HashMap<String, Object>();
		try{
			StringTokenizer st = new StringTokenizer(sqlListStr, "}");
			String sqlCont = "";
			while(st.hasMoreTokens()){
				String sqlElement = st.nextToken();
				if(sqlElement.indexOf("{") > -1){
					String tmp = sqlElement.substring(sqlElement.indexOf(":"));
					sqlCont += tmp.substring(tmp.indexOf("\"") + 1, tmp.lastIndexOf("\"")) + "\n";
				}
			}
			
			
			if(!"".equals(sqlCont)){
				sqlCont = sqlCont.replaceAll("@br@", "\n");
				File sqlFile = new File(uploadPath + "/db_patch.sql");
	
			    try {
				    FileWriter fw = new FileWriter(sqlFile);
				    fw.write(sqlCont);
				    fw.close();
			    } catch (IOException e) {
			    	logger.error("[ERROR] - File Writer Error : " + e.getMessage());
			    	result = false;
			    }
			}
		    
			String libCont = "";
			int parsingCnt = StringUtils.countMatches(libPatchMapStr, "]}");
			
			for(int i=0; i<parsingCnt; i++){
				String tokenStr = libPatchMapStr.substring(0, libPatchMapStr.indexOf("]}") + 1);
				String libName = "";
				String libProc = "";
				if(StringUtils.countMatches(tokenStr, ":") == 2){
					libName = tokenStr.split(":")[1];
					libName = libName.substring(libName.indexOf("\"") + 1);
					libName = libName.substring(0, libName.indexOf("\"")).trim();
					
					libProc = tokenStr.split(":")[2].replace("[", "").replace("]", "");
				}else{
					String oldLibName = tokenStr.split(":")[1];
					oldLibName = oldLibName.substring(oldLibName.indexOf("\"") + 1).trim();
					
					libName = tokenStr.split(":")[2];
					libName = libName.substring(0, libName.indexOf("\"")).trim();
					libName = oldLibName + ".jar:" + libName;
					
					libProc = tokenStr.split(":")[3].replace("[", "").replace("]", "");
				}
				
				StringTokenizer lst = new StringTokenizer(libProc, ",");			
				while(lst.hasMoreTokens()){
					String procName = lst.nextToken();
					procName = procName.substring(procName.indexOf("\"") + 1);
					procName = procName.substring(0, procName.indexOf("\"")).trim();
					libCont +=  procName + " " + libName + "\n";
				}
				libPatchMapStr = libPatchMapStr.substring(libPatchMapStr.indexOf("]}") + 2);
			}
			
			if(!"".equals(libCont)){
				File libFile = new File(uploadPath + "/lib/lib.info");
	
			    try {
				    FileWriter lfw = new FileWriter(libFile);
				    lfw.write(libCont);
				    lfw.close();
			    } catch (IOException e) {
			    	logger.error("[ERROR] - File Writer Error : " + e.getMessage());
			    	result = false;
			    }
			}
	
			File contFile = new File(uploadPath + "/patch.info");
	
		    try {
			    FileWriter cfw = new FileWriter(contFile);
			    cfw.write(patchCont);
			    cfw.close();
		    } catch (IOException e) {
		    	logger.error("[ERROR] - File Writer Error : " + e.getMessage());
		    	result = false;
		    }
		    
			zipFolder(uploadPath, fileName);
			removeDirectory(uploadPath);
			String patchZipFilePath = AdminConfig.getString("upload_path") + "patch_gen/" + fileName + ".zip";
			File patchZipFile = new File(patchZipFilePath);
			Date now = new Date();
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			
			long fileSizeNum = patchZipFile.length();
			double norFileSizeNum = 0;
			String fileSize = "";
			if(fileSizeNum > 1024 * 1024){
				norFileSizeNum = fileSizeNum / (1024 * 1024) + fileSizeNum % (1024 * 1024);
				fileSize = String.format("%.2f" , norFileSizeNum) + " MB ( " + String.valueOf(fileSizeNum) + " bytes )";
			}else if(fileSizeNum > 1024){
				fileSizeNum = fileSizeNum / 1024 + fileSizeNum % 1024;
				fileSize = String.format("%.2f" , norFileSizeNum) + " KB ( " + String.valueOf(fileSizeNum) + " bytes )";
			}else{
				fileSize = String.valueOf(fileSizeNum) + " bytes";
			}
			
			param.put("file_name", fileName);
			param.put("file_path", patchZipFilePath);
			param.put("file_size", fileSize);
			param.put("file_md5", FileUtil.md5Hex(patchZipFile));
			param.put("patch_target", procListStr.replace("[", "").replace("]", "").replaceAll("\"", "").replaceAll(",", ", "));
			param.put("reg_dt", sdf.format(now));
			
			param.put("file_cont", patchCont);
			param.put("proc_id", session.getAttribute(Constants.USER_ID));
			param.put("proc_ip", req.getRemoteAddr());
			dao.insertPatchFileInfo(param);
		}catch(Exception e){
			logger.error(e.getMessage());
		}
		return reFac.getJsonResultEntity(result);
	}
	
	public void removeDirectory(String srcPath){
		File[] listFiles = new File(srcPath).listFiles(); 
		try{
			if(listFiles.length > 0){
				for(int i = 0 ; i < listFiles.length ; i++){
					if(listFiles[i].isFile()){
						listFiles[i].delete(); 
					}else{
						removeDirectory(listFiles[i].getPath());
					}
				}
			}
			
			listFiles = new File(srcPath).listFiles();
			if(listFiles.length == 0){
				File srcDir = new File(srcPath);
				srcDir.delete();
			}
		}catch(Exception e){
			logger.error("[ERROR] - Directory Delete Error : " + e.getMessage());
		}
	}
	
	public void zipFolder(String folderPath, String fileName) throws IOException{
		File dir = new File(folderPath);
        File file = null;
        String files[] = null;
  
        if( dir.isDirectory() ){
            files = dir.list();
        }else{
            files = new String[1];
            files[0] = dir.getName();
        }
 
        ZipArchiveOutputStream zos = null;
          
        try {
            zos = new ZipArchiveOutputStream(new BufferedOutputStream(new FileOutputStream(AdminConfig.getString("upload_path") + "patch_gen/" + fileName + ".zip")));
              
            for( int i=0; i < files.length; i++ ){
                file = new File(folderPath + "/" + files[i]);
                zip("", file, zos, folderPath);
            }
            zos.close();
  
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }finally{
            if( zos != null ){
                zos.close();
            }
        }
	}
	public static void zip(String parent, File file, ZipArchiveOutputStream zos, String folderPath) throws IOException{
        
        FileInputStream fis = null;
        BufferedInputStream bis = null;
         
        //buffer size
        int size = 1024;
        byte[] buf = new byte[size];
         
        if( !file.exists() ){
            logger.error("[ERROR] - " + file.getName() + " : 파일없음");
        }
         
        if( file.isDirectory() ){
            String dirName = "";
            if(file.getPath().indexOf("\\") > -1){
            	dirName = file.getPath().replace("\\", "/").replace(folderPath, "");
            }else{
            	dirName = file.getPath().replace(folderPath, "");
            }
            String parentName = dirName.substring(1) + "/";
            dirName = dirName.substring(1,dirName.length() - file.getName().length());
            ZipArchiveEntry entry = new ZipArchiveEntry(dirName + file.getName() + "/");
            zos.putArchiveEntry(entry);
            String[] files = file.list();
            for( int i=0; i<files.length; i++ ){
                zip(parentName, new File(file.getPath() + "/" + files[i]), zos, folderPath);
            }
     
        }else{
             //encoding 설정
            zos.setEncoding("UTF-8");
            fis = new FileInputStream(file);
            bis = new BufferedInputStream(fis,size);
              
            
            ZipArchiveEntry entry = new ZipArchiveEntry(parent+file.getName());
            zos.putArchiveEntry(entry);
              
              
            int len;
            while((len = bis.read(buf,0,size)) != -1){
                zos.write(buf,0,len);
            }
              
            bis.close();
            fis.close();
            zos.closeArchiveEntry();
        }
    }
}