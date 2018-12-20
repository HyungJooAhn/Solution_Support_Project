package com.seculayer.web.tist.dao;

import java.util.List;
import java.util.Map;

public interface VXShareDAO {
	
	public int selectVXShareFileCount(Map<String,Object> map);
	public List<Map<String, Object>> selectVXShareFileList(Map<String,Object> map);
	public List<Map<String, Object>> selectVXShareFileAllList(Map<String,Object> map);
	public List<Map<String, Object>> selectVXShareDataList(Map<String,Object> map);
	public Map<String, Object> getRows(Map<String,Object> map);
	public Map<String, Object> selectVXShareDataBySeq(Map<String,Object> map);
}
