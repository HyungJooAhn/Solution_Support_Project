package com.seculayer.web.download.dao;

import java.util.List;
import java.util.Map;

public interface PackageDownloadDAO {

	public List<Map<String,Object>> selectDownloadList(Map<String,Object> map);
	public Map<String,Object> selectDownloadPatchDetail(Map<String,Object> map);
	public List<Map<String,Object>> selectDelFileInfo(Map<String,Object> map);
	public int downloadMenufileDelete(Map<String,Object> map);
	public List<Map<String,Object>> checkExistenceFile(Map<String,Object> map);
	public int insertFileData(Map<String,Object> map);
	public int updateFile(Map<String,Object> map);
	public int updateDownloadUseYn(Map<String,Object> map);
	public int downloadCntUp(Map<String,Object> map);
	
	public int selectComUserRole(String userId);
	public int patchFileListCount(Map<String, Object> map);
	public List<Map<String, Object>> patchFileList(Map<String, Object> map);
	public int patchFileNameDupCheck(Map<String, Object> map);
	public int insertPatchFileInfo(Map<String,Object> map);
	public Map<String, Object> selectFileInfoByID(Map<String, Object> map);
	public void patchFileDelete(Map<String, Object> map);
}
