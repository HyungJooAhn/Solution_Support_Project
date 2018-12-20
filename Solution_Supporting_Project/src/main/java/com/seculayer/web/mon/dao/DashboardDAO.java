package com.seculayer.web.mon.dao;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public interface DashboardDAO {
	public int selectParserCnt();
	public int selectLogParserCnt();
	public int selectEventCnt();
	public int selectSenEventCnt();
	public int selectRelEventCnt();
	public int selectBlackListCnt();
	public int selectVXShareCnt();
	
	public int selectRelTICnt();
	public int selectIndicatorTICnt();
	public int selectRSSTICnt();
	public int selectCollectTICnt();
	public int selectAnalysisTICnt();
	
	public int selectV31ALLCnt();
	public int selectV31PatchCnt();
	
	public int selectV30ALLCnt();
	public int selectV30PatchCnt();
	
	public int selectV25ALLCnt();
	public int selectV25PatchCnt();
	
	public int selectIssueNewCnt();
	public int selectIssueCnt(Map<String, Object> param);
	
	public ArrayList<Map<String,Object>> selectReservationList(Map<String, Object> param);
	
	public ArrayList<Map<String,Object>> selectBoardCnt();
	
	public ArrayList<HashMap<String,Object>> selectNationList_v30();
	public ArrayList<HashMap<String,Object>> selectNationList_v31();
	
	public ArrayList<HashMap<String,Object>> selectNationIPList_v30();
	public ArrayList<HashMap<String,Object>> selectNationIPList_v31();
	
	public int checkVisitorIP(Map<String, Object> map);
	public int insertTodayVisitor(Map<String, Object> map);
	public int deleteOldVisitor(Map<String, Object> map);
	
	public int selectVisitorCnt(Map<String, Object> map);
	
}
