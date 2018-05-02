<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="weaver.general.Util,weaver.hrm.common.*,weaver.conn.*,weaver.systeminfo.*" %>
<%@ page import="weaver.hrm.attendance.domain.*,weaver.hrm.User"%>
<jsp:useBean id="strUtil" class="weaver.common.StringUtil" scope="page" />
<jsp:useBean id="dateUtil" class="weaver.common.DateUtil" scope="page" />
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />
<%
	User user = (User)request.getSession(true).getAttribute("weaver_user@bean");
	int nodetype = strUtil.parseToInt(request.getParameter("nodetype"), 0);
	int workflowid = strUtil.parseToInt(request.getParameter("workflowid"), 0);
	int formid = strUtil.parseToInt(request.getParameter("formid"));
	int userid = strUtil.parseToInt(request.getParameter("userid"));
	String creater = strUtil.vString(request.getParameter("creater"), String.valueOf(userid));
	int requestId = Util.getIntValue(request.getParameter("requestid"));
	int currentnodetype = Util.getIntValue((String)session.getAttribute(user.getUID()+"_"+requestId+"currentnodetype"),0);
	String currentdate = strUtil.vString(request.getParameter("currentdate"), dateUtil.getCurrentDate());
	String f_weaver_belongto_userid = strUtil.vString(request.getParameter("f_weaver_belongto_userid"));
	String f_weaver_belongto_usertype = strUtil.vString(request.getParameter("f_weaver_belongto_usertype"));
	
	String ccksrq = "";//出差开始日期
	String ccjsrq = "";//出差结束日期
	String cckssj = "";//出差开始时间
	String ccjssj = ""; //出差结束时间
	rs.executeSql("select id,fieldname from workflow_billfield where billid = " + formid + " ");
	while(rs.next()){
		String fieldnameStrTemp = Util.null2String(rs.getString("fieldname")); 
		if("ccksrq".equals(fieldnameStrTemp))
			ccksrq = "field" + Util.null2String(rs.getString("id"));
		if("ccjsrq".equals(fieldnameStrTemp))
			ccjsrq = "field" + Util.null2String(rs.getString("id"));
		if("sj1".equals(fieldnameStrTemp))
			cckssj = "field" + Util.null2String(rs.getString("id"));
		if("sj2".equals(fieldnameStrTemp))
			ccjssj = "field" + Util.null2String(rs.getString("id"));
	}
%>

<script language="javascript">
var nodetype = "<%=nodetype%>";
var workflowid = "<%=workflowid%>";
var formid = "<%=formid%>";
var userid = "<%=userid%>";
var requestId = "<%=requestId%>";
var currentnodetype = "<%=currentnodetype%>";
var _field_ccksrq = "<%=ccksrq%>";
var _field_ccjsrq = "<%=ccjsrq%>";
var _field_cckssj = "<%=cckssj%>";
var _field_ccjssj = "<%=ccjssj%>";
var f_weaver_belongto_userid = "<%=f_weaver_belongto_userid%>";
var f_weaver_belongto_usertype = "<%=f_weaver_belongto_usertype%>";

function ajaxInit(){
	var ajax=false;
	try {
		ajax = new ActiveXObject("Msxml2.XMLHTTP");
	} catch (e) {
		try {
			ajax = new ActiveXObject("Microsoft.XMLHTTP");
		} catch (E) {
			ajax = false;
		}
	}
	if (!ajax && typeof XMLHttpRequest!='undefined') {
		ajax = new XMLHttpRequest();
	}
	return ajax;
}

jQuery(document).ready(function(){
	if(currentnodetype == 0) {
		newCheckCustomize();
	}
});
	
function bindEvent(func){
	checkCustomize = func;
}
	
function newCheckCustomize() {
	bindEvent(function() {
		var returnStr = true;
		returnStr = checkDate();
		if(returnStr){
			returnStr = checkTime();
		}
		if(returnStr){
			returnStr = checkDate();
		}
		return returnStr;
	});
}
//市内公出流程只能提前请
function checkDate(){
		var str = true;
		var begindate = jQuery("#" + _field_ccksrq).val();
		var begintime = jQuery("#" + _field_cckssj).val();
		if (begindate != "" && begintime != "") {
			var today = new Date();
			var year = today.getFullYear();
			var month = today.getMonth() + 1;
			var date = today.getDate();
			var monthStr = month;
			var hour = today.getHours();
			var minutes = today.getMinutes();
			if (month < 10)
				monthStr = "0" + monthStr;
			if (date < 10)
				date = "0" + date;
			if (hour < 10)
				hour = "0" + hour;
			if (minutes < 10)
				minutes = "0" + minutes;
			var currentdate = year + "-" + monthStr + "-" + date;
			var currenttime = hour + ":" + minutes;

			var beginD = new Date((begindate + " " + begintime + ":00").replace(/-/g,"\/"));
			var currentD = new Date((currentdate + " " + currenttime + ":00").replace(/-/g,"\/"));
			if(currentD > beginD) {
				alert("市内公出流程只能提前请！");
				str =  false;
			}
		}
		return str;
}

function checkTime(){
		var str = true;
		var begintime = jQuery("#" + _field_cckssj).val();
		var endtime = jQuery("#" + _field_ccjssj).val();
		if(begintime != "" && endtime !=""){
			if((begintime < "08:30") || (endtime > "17:00")) {
				//alert("begintime="+begintime+"||endtime="+endtime);
					window.top.Dialog.alert("请假流程时间为8:30-17:00，其他时间不允许提交！");
					str = false;
				}
			}
			return str;
}

//开始时间必须小于结束时间
function checkDate(){
	var str = true;
	var beginDay = jQuery("#" + _field_ccksrq).val();//出差开始日期
	var endDay = jQuery("#" + _field_ccjsrq).val();//出差结束日期
	var begintime = jQuery("#" + _field_cckssj).val();//出差开始时间
	var endtime = jQuery("#" + _field_ccjssj).val();//出差结束时间
	var beginD = new Date((beginDay + " " + begintime + ":00").replace(/-/g,"\/"));
	var endD = new Date((endDay + " " + endtime + ":00").replace(/-/g,"\/"));
	//alert("beginD="+beginD+"||endD="+endD);
	if(beginD > endD) {
		alert("结束日期早于开始日期，流程不允许提交！");
		str =  false;
	}
	return  str;
}

</script>