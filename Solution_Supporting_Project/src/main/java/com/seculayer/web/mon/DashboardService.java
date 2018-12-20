package com.seculayer.web.mon;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import com.seculayer.web.mon.dao.DashboardDAO;


@Controller
@RequestMapping(value = "/mon/")
public class DashboardService {
	
	@Autowired private SqlSession sqlSession;
	
	static Logger logger = Logger.getLogger(DashboardService.class);

	public HashMap<String,Object> getContentsStatus() {
		DashboardDAO dao = sqlSession.getMapper(DashboardDAO.class);
		
		HashMap<String, Object> result = new HashMap<String, Object>();
		int parserCnt = dao.selectParserCnt();
		result.put("parser", parserCnt);
		
		int logParserCnt = dao.selectLogParserCnt();
		result.put("log_parser", logParserCnt);
		
		int eventCnt = dao.selectEventCnt();
		result.put("event", eventCnt);
		
		int senEventCnt = dao.selectSenEventCnt();
		result.put("senario_event", senEventCnt);
		
		int relEventCnt = dao.selectRelEventCnt();
		result.put("rel_event", relEventCnt);
		
		int blacklistCnt = dao.selectBlackListCnt();
		result.put("blacklist", blacklistCnt * 2);
		
		int vxShareCnt = dao.selectVXShareCnt();
		result.put("vxshare", vxShareCnt);
		
		return result;
	}
	
	public HashMap<String,Object> getTIStatus() {
		DashboardDAO dao = sqlSession.getMapper(DashboardDAO.class);
		HashMap<String, Object> result = new HashMap<String, Object>();
		
		int relationCnt = dao.selectRelTICnt();
		result.put("relation", relationCnt);
		
		int indicatorCnt = dao.selectIndicatorTICnt();
		result.put("indicator", indicatorCnt);
		
		int rssCnt = dao.selectRSSTICnt();
		result.put("rss", rssCnt);
		
		int collectCnt = dao.selectCollectTICnt();
		result.put("collect", collectCnt);
		
		int analysisCnt = dao.selectAnalysisTICnt();
		result.put("analysis", analysisCnt);
		
		return result;
	}
	
	public HashMap<String,Object> getDownloadStatus() {
		DashboardDAO dao = sqlSession.getMapper(DashboardDAO.class);
		HashMap<String, Object> result = new HashMap<String, Object>();
		
		int v31_all_in_one_Cnt = dao.selectV31ALLCnt();
		result.put("v31_all_in_one", v31_all_in_one_Cnt);
		
		int v31_patch_Cnt = dao.selectV31PatchCnt();
		result.put("v31_patch", v31_patch_Cnt);
		
		int v30_all_in_one_Cnt = dao.selectV30ALLCnt();
		result.put("v30_all_in_one", v30_all_in_one_Cnt);
		
		int v30_patch_Cnt = dao.selectV30PatchCnt();
		result.put("v30_patch", v30_patch_Cnt);
		
		int v25_all_in_one_Cnt = dao.selectV25ALLCnt();
		result.put("v25_all_in_one", v25_all_in_one_Cnt);
		
		int v25_patch_Cnt = dao.selectV25PatchCnt();
		result.put("v25_patch", v25_patch_Cnt);
		
		return result;
	}
	
	public HashMap<String,Object> getIssueStatus() {
		DashboardDAO dao = sqlSession.getMapper(DashboardDAO.class);
		HashMap<String, Object> result = new HashMap<String, Object>();
		
		int issueNew = dao.selectIssueNewCnt();
		result.put("new", issueNew);
		
		Map<String, Object> param = new HashMap<String, Object>();
		
		param.put("issue_cd", 10);
		int issueImprove = dao.selectIssueCnt(param);
		result.put("improve", issueImprove);
		
		param.put("issue_cd", 20);
		int issueError = dao.selectIssueCnt(param);
		result.put("error", issueError);
		
		param.put("issue_cd", 99);
		int issueEtc = dao.selectIssueCnt(param);
		result.put("etc", issueEtc);
		
		return result;
	}
	
	public ArrayList<Map<String,Object>> getReservationList(Map<String, Object> map) {
		DashboardDAO dao = sqlSession.getMapper(DashboardDAO.class);
		ArrayList<Map<String,Object>> result = dao.selectReservationList(map);
		
		return result;
	}
	
	public HashMap<String,Object> getBoardStatus() {
		DashboardDAO dao = sqlSession.getMapper(DashboardDAO.class);
		HashMap<String, Object> result = new HashMap<String, Object>();
		
		ArrayList<Map<String, Object>> list = dao.selectBoardCnt();
		int boardLab = 0;
		int boardSales = 0;
		int boardBsup = 0;
		int boardTS = 0;
		int boardBus = 0;
		int boardNewTech = 0;
		int boardConsulting = 0;
		int boardService = 0;
		int boardTech = 0;
		int boardManual = 0;
		int boardSecu = 0;
		
		for(int i=0; i<list.size(); i++){
			String typeCd = list.get(i).get("type_cd").toString();
			switch(typeCd){
			case "96903840493731962":
				boardLab ++;
				break;
			case "97674185911828737":
				boardSales ++;
				break;
			case "97674185911828745":
				boardBsup ++;
				break;
			case "96903840493731964":
				boardTS ++;
				break;
			case "96903840493731974":
				boardBus ++;
				break;
			case "96903840493731966":
				boardNewTech ++;
				break;
			case "96903840493731968":
				boardConsulting ++;
				break;
			case "96903840493731970":
				boardService ++;
				break;
			case "96903840493731976":
				boardTech ++;
				break;
			case "96903840493731972":
				boardManual ++;
				break;
			case "97674185911828753":
				boardSecu ++;
				break;
			}
		}
		
		result.put("laboratory", boardLab);
		result.put("sales", boardSales);
		result.put("business_sup", boardBsup);
		result.put("TS", boardTS);
		result.put("business", boardBus);
		result.put("new_tech", boardNewTech);
		result.put("consulting", boardConsulting);
		result.put("service", boardService);
		result.put("tech", boardTech);
		result.put("manual", boardManual);
		result.put("secu", boardSecu);
		
		return result;
	}
	
	public ArrayList<HashMap<String,Object>> getNationList() {
		DashboardDAO dao = sqlSession.getMapper(DashboardDAO.class);
		ArrayList<HashMap<String,Object>> result_v30 = dao.selectNationList_v30();
		/*ArrayList<HashMap<String,Object>> result_v31 = dao.selectNationList_v31();
		for(int i=0; i<result_v31.size(); i++){
			int tmpCnt = 0;
			for(int k=0; k<result_v30.size(); k++){
				if(result_v31.get(i).get("nation").toString().equals(result_v30.get(k).get("nation").toString())){
					int setCnt = Integer.parseInt(result_v30.get(i).get("count").toString()) * + Integer.parseInt(result_v31.get(i).get("count").toString());
					result_v30.get(i).put("count", setCnt);
					break;
				}
				tmpCnt ++;
			}
			if(tmpCnt == result_v30.size()){
				result_v30.add(result_v31.get(i));
			}
		}*/
		
		return result_v30;
	}
	
	public ArrayList<HashMap<String,Object>> getNationIPList() {
		DashboardDAO dao = sqlSession.getMapper(DashboardDAO.class);
		ArrayList<HashMap<String,Object>> result_v30 = dao.selectNationIPList_v30();
	/*	ArrayList<HashMap<String,Object>> result_v31 = dao.selectNationIPList_v31();
		
		for(int i=0; i<result_v31.size(); i++){
			result_v30.add(result_v31.get(i));
		}*/
		return result_v30;
	}
	
	public Map<String,Object> getTodayList(Map<String, Object> param) {
		DashboardDAO dao = sqlSession.getMapper(DashboardDAO.class);
		Map<String, Object> result = new HashMap<String, Object>();
		SimpleDateFormat mSimpleDateFormat = new SimpleDateFormat ( "yyyy-MM-dd", Locale.KOREA );
		ArrayList<String> dbDayList =  new ArrayList<String>();
		
		Calendar cal = new GregorianCalendar();
		String dbDay = "";
		
		cal.add(Calendar.DATE, -7);
		Date date = cal.getTime();
		dbDay = mSimpleDateFormat.format(date);
		dbDayList.add(dbDay);
		
		for(int k=0; k<5; k++){
			cal.add(Calendar.DATE, 1);
			date = cal.getTime();
			dbDay = mSimpleDateFormat.format(date);
			dbDayList.add(dbDay);
		}
		param.put("db_day_list", dbDayList);

		cal.add(Calendar.DATE, 1);
	    date = cal.getTime();
		String yesterday = mSimpleDateFormat.format(date);
		
	    cal.add(Calendar.DATE, 1);
	    date = cal.getTime();
		String today = mSimpleDateFormat.format(date);
		
		param.put("date", today);
		
		dao.deleteOldVisitor(param);
		int checkIP = dao.checkVisitorIP(param);
		if(checkIP == 0){
			dao.insertTodayVisitor(param);
		}
		int todayVisitor = dao.selectVisitorCnt(param);
		result.put("today", todayVisitor);
		
		param.put("date", yesterday);
		int yesterdayVisitor = dao.selectVisitorCnt(param);
		result.put("yesterday", yesterdayVisitor);
		
		return result;
	}
	
}
