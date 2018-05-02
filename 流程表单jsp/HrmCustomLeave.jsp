<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="weaver.general.Util,weaver.hrm.common.*,weaver.conn.*,weaver.systeminfo.*" %>
<%@ page import="weaver.hrm.attendance.domain.*,weaver.hrm.User"%>
<%@ page import="weaver.hrm.schedule.HrmAnnualManagement"%>
<%@ page import="weaver.hrm.schedule.HrmPaidSickManagement"%>
<!-- Added by wcd 2015-06-25[自定义请假单] -->
<jsp:useBean id="strUtil" class="weaver.common.StringUtil" scope="page" />
<jsp:useBean id="dateUtil" class="weaver.common.DateUtil" scope="page" />
<jsp:useBean id="attProcSetManager" class="weaver.hrm.attendance.manager.HrmAttProcSetManager" scope="page" />
<jsp:useBean id="attVacationManager" class="weaver.hrm.attendance.manager.HrmAttVacationManager" scope="page" />
<jsp:useBean id="paidLeaveTimeManager" class="weaver.hrm.attendance.manager.HrmPaidLeaveTimeManager" scope="page" />
<%
	User user = (User)request.getSession(true).getAttribute("weaver_user@bean");
	int nodetype = strUtil.parseToInt(request.getParameter("nodetype"), 0);
	int workflowid = strUtil.parseToInt(request.getParameter("workflowid"), 0);
	int formid = strUtil.parseToInt(request.getParameter("formid"));
	int requestId = Util.getIntValue(request.getParameter("requestid"));
	int currentnodetype = Util.getIntValue((String)session.getAttribute(user.getUID()+"_"+requestId+"currentnodetype"),0);
	int userid = strUtil.parseToInt(request.getParameter("userid"));
	String creater = strUtil.vString(request.getParameter("creater"), String.valueOf(userid));
	String[] fieldList = attProcSetManager.getFieldList(workflowid, formid);
	if(fieldList == null || fieldList.length == 0 || strUtil.isNull(fieldList[0])) return;
	String currentdate = strUtil.vString(request.getParameter("currentdate"), dateUtil.getCurrentDate());
	String f_weaver_belongto_userid = strUtil.vString(request.getParameter("f_weaver_belongto_userid"));
	String f_weaver_belongto_usertype = strUtil.vString(request.getParameter("f_weaver_belongto_usertype"));
	String userannualinfo = HrmAnnualManagement.getUserAannualInfo(creater,currentdate);
	String thisyearannual = Util.TokenizerString2(userannualinfo,"#")[0];
	String lastyearannual = Util.TokenizerString2(userannualinfo,"#")[1];
	String allannual = Util.TokenizerString2(userannualinfo,"#")[2];
	String userpslinfo = HrmPaidSickManagement.getUserPaidSickInfo(creater, currentdate);
	String thisyearpsldays = ""+Util.getFloatValue(Util.TokenizerString2(userpslinfo,"#")[0], 0);
	String lastyearpsldays = ""+Util.getFloatValue(Util.TokenizerString2(userpslinfo,"#")[1], 0);
	String allpsldays = ""+Util.getFloatValue(Util.TokenizerString2(userpslinfo,"#")[2], 0);
	String paidLeaveDays = String.valueOf(paidLeaveTimeManager.getCurrentPaidLeaveDaysByUser(creater));
	String allannualValue = allannual;
	String allpsldaysValue = allpsldays;
	String paidLeaveDaysValue = paidLeaveDays;
	float[] freezeDays = attVacationManager.getFreezeDays(creater);
	if(freezeDays[0] > 0) allannual += " - "+freezeDays[0];
	if(freezeDays[1] > 0) allpsldays += " - "+freezeDays[1];
	if(freezeDays[2] > 0) paidLeaveDays += " - "+freezeDays[2];
	
	float realAllannualValue = strUtil.parseToFloat(allannualValue, 0);
	float realAllpsldaysValue = strUtil.parseToFloat(allpsldaysValue, 0);
	float realPaidLeaveDaysValue = strUtil.parseToFloat(paidLeaveDaysValue, 0);
	if(attProcSetManager.isFreezeNode(workflowid, nodetype)) {
		realAllannualValue = (float)strUtil.round(realAllannualValue - freezeDays[0]);
		realAllpsldaysValue = (float)strUtil.round(realAllpsldaysValue - freezeDays[1]);
		realPaidLeaveDaysValue = (float)strUtil.round(realPaidLeaveDaysValue - freezeDays[2]);
	}
%>
<script language="javascript">
	var workflowid = "<%=workflowid%>";
	var formid = "<%=formid%>";
	var currentnodetype = "<%=currentnodetype%>";
	var _field_resourceId = "<%=fieldList[0]%>";
	var _field_newLeaveType = "<%=fieldList[2]%>";
	var _field_fromDate = "<%=fieldList[3]%>";
	var _field_fromTime = "<%=fieldList[4]%>";
	var _field_toDate = "<%=fieldList[5]%>";
	var _field_toTime = "<%=fieldList[6]%>";
	var _field_leaveDays = "<%=fieldList[7]%>";
	var _field_vacationInfo = "<%=fieldList[8]%>";
	var f_weaver_belongto_userid = "<%=f_weaver_belongto_userid%>";
	var f_weaver_belongto_usertype = "<%=f_weaver_belongto_usertype%>";

	var allannualValue="<%=allannualValue%>";
	var allpsldaysValue="<%=allpsldaysValue%>";
	var paidLeaveDaysValue="<%=paidLeaveDaysValue%>";
	var realAllannualValue="<%=realAllannualValue%>";
	var realAllpsldaysValue="<%=realAllpsldaysValue%>";
	var realPaidLeaveDaysValue="<%=realPaidLeaveDaysValue%>";

	var ua = navigator.userAgent.toLowerCase();
	var s;
	s = ua.match(/msie ([\d.]+)/);
	
	if(s && parseInt(s[1]) <= 8){
		window.onload = function(){
			if(_field_vacationInfo != "") {
				try{
					$GetEle(_field_vacationInfo).style.display = "none";
					showVacationInfo();
					
				}catch(e){}
			}
			if(_field_leaveDays != "") {
				try{
					$GetEle(_field_leaveDays).style.display = "none";
					jQuery("#"+_field_leaveDays+"span").html(jQuery("input[name='"+_field_leaveDays+"']").val());
				}catch(e){}
			}
		}
	}else{
		jQuery(document).ready(function(){
			if(_field_vacationInfo != "") {
				try{
					$GetEle(_field_vacationInfo).style.display = "none";
					showVacationInfo();
					
				}catch(e){}
			}
			if(_field_leaveDays != "") {
				try{
					$GetEle(_field_leaveDays).style.display = "none";
					jQuery("#"+_field_leaveDays+"span").html(jQuery("input[name='"+_field_leaveDays+"']").val());
				}catch(e){}
			}
		});
	}
	
	
	function onShowTimeCallBack(id) {
		var fieldid = id.split("_")[0];
		var rowindex = id.split("_")[1];
		wfbrowvaluechange_fna(null, fieldid, rowindex);
	}
	
	function wfbrowvaluechange_fna(obj, fieldid, rowindex) {
		fieldid = "field"+fieldid;
		if(fieldid == _field_vacationInfo){ showVacationInfo();
		}else if(fieldid == _field_fromDate || fieldid == _field_fromTime || fieldid == _field_toDate || fieldid == _field_toTime){setLeaveDays();
			if(fieldid == _field_fromDate) {
				initInfo();
			}
	    }else if(fieldid == _field_resourceId){
			setLeaveDays();
			initInfo();
		}
	}

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

	function setLeaveDays(){
		if(_field_leaveDays == "") return;
		
		var resourceId = jQuery("input[name='"+_field_resourceId+"']").val();
		var fromDate = jQuery("input[name='"+_field_fromDate+"']").val();
		var fromTime = jQuery("input[name='"+_field_fromTime+"']").val();
		var toDate = jQuery("input[name='"+_field_toDate+"']").val();
		var toTime = jQuery("input[name='"+_field_toTime+"']").val();
		var leaveDaysObj = jQuery("input[name='"+_field_leaveDays+"']");
		var leaveDyasType = leaveDaysObj.attr("type");
		
		if(resourceId != '' && fromDate!='' && toDate!=''){
			var ajax=ajaxInit();
			ajax.open("POST", "/workflow/request/BillBoHaiLeaveXMLHTTP.jsp", true);
			ajax.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
			ajax.send("operation=getLeaveDays&f_weaver_belongto_userid="+f_weaver_belongto_userid+"&f_weaver_belongto_usertype="+f_weaver_belongto_usertype+"&fromDate="+fromDate+"&fromTime="+fromTime+"&toDate="+toDate+"&toTime="+toTime+"&resourceId="+resourceId);
			ajax.onreadystatechange = function() {
				if (ajax.readyState == 4 && ajax.status == 200) {
					try {
						var result = trim(ajax.responseText);
						leaveDaysObj.val(result);
						//if(leaveDyasType == 'hidden') 
						jQuery("#"+_field_leaveDays+"span").html(result);
					} catch(e) {
						leaveDaysObj.val("0.0");
						//if(leaveDyasType == 'hidden') 
						jQuery("#"+_field_leaveDays+"span").html('0.0');
					}
				}
			}
		}
		showVacationInfo();
	}
function initInfo(){
		
		var resourceId = jQuery("input[name='"+_field_resourceId+"']").val();
		var fromDate = jQuery("input[name='"+_field_fromDate+"']").val();
		if(resourceId != ''){
			var ajax=ajaxInit();
			ajax.open("POST", "/workflow/request/BillBoHaiLeaveXMLHTTP.jsp", true);
			ajax.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
			ajax.send("operation=initInfo&nodetype=<%=nodetype%>&workflowid=<%=workflowid%>&resourceId="+resourceId+"&currentDate="+fromDate);
			ajax.onreadystatechange = function() {
				if (ajax.readyState == 4 && ajax.status == 200) {
					try {
						 var result = trim(ajax.responseText);
						 allannualValue=result.split("#")[0];
						 allpsldaysValue=result.split("#")[1];
						 paidLeaveDaysValue=result.split("#")[2];
						 realAllannualValue=result.split("#")[3];
						 realAllpsldaysValue=result.split("#")[4];
						 realPaidLeaveDaysValue=result.split("#")[5];
					} catch(e) {
						
					}
				}
			}
		}
	}	
	
	
function getAnnualInfo(resourceId) {
	if(typeof(resourceId) != "undefined" && resourceId != "") {//归档后查看页面中，页面上不存在name的元素
	    var ajax=ajaxInit();
	    ajax.open("POST", "/workflow/request/BillBoHaiLeaveXMLHTTP.jsp", true);
	    ajax.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
	    ajax.send("operation=getAnnualInfo&resourceId="+resourceId+"&currentDate=<%=currentdate%>");
	    ajax.onreadystatechange = function() {
	    	if (ajax.readyState == 4 && ajax.status == 200) {
	    		try{
	    			var annualInfo=trim(ajax.responseText).split("#")[1];
					if(annualInfo == "") {
						//alert("<%=SystemEnv.getHtmlLabelName(125565, user.getLanguage())%>");
						return;
					} else {
						$GetEle(_field_vacationInfo).style.display = "none";
		                jQuery("#"+_field_vacationInfo+"span").html(annualInfo);
						jQuery("#"+_field_vacationInfo).val(annualInfo);
					}
				}catch(e){
					//alert("<%=SystemEnv.getHtmlLabelName(125565, user.getLanguage())%>");
					return;
				}
			}
	    }
	}
}
function getPSInfo(resourceId) {
	//alert(resourceId + "===getPSInfo");
	if(typeof(resourceId) != "undefined" && resourceId != "") {//归档后查看页面中，页面上不存在name的元素
	    var ajax=ajaxInit();
	    ajax.open("POST", "/workflow/request/BillBoHaiLeaveXMLHTTP.jsp", true);
	    ajax.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
	    ajax.send("operation=getPSInfo&resourceId="+resourceId+"&currentDate=<%=currentdate%>");
	    ajax.onreadystatechange = function() {
	    	if (ajax.readyState == 4 && ajax.status == 200) {
	    		try{
	    			var PSInfo=trim(ajax.responseText).split("#")[1];
					if(PSInfo == "") {
						//alert("<%=SystemEnv.getHtmlLabelName(125566, user.getLanguage())%>");
						return;
					} else {
						$GetEle(_field_vacationInfo).style.display = "none";
		                jQuery("#"+_field_vacationInfo+"span").html(PSInfo);
						jQuery("#"+_field_vacationInfo).val(PSInfo);
					}
				}catch(e){
					//alert("<%=SystemEnv.getHtmlLabelName(125566, user.getLanguage())%>");
					return;
				}
			}
	    }
	}
}
function getTXInfo(resourceId) {
	//alert(resourceId + "===getPSInfo");
	if(typeof(resourceId) != "undefined" && resourceId != "") {//归档后查看页面中，页面上不存在name的元素
	    var ajax=ajaxInit();
	    ajax.open("POST", "/workflow/request/BillBoHaiLeaveXMLHTTP.jsp", true);
	    ajax.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
		var fromDate = jQuery("input[name='"+_field_fromDate+"']").val();
	    ajax.send("operation=getTXInfo&resourceId="+resourceId+"&currentDate="+fromDate);
	    ajax.onreadystatechange = function() {
	    	if (ajax.readyState == 4 && ajax.status == 200) {
	    		try{
	    			var TXInfo=trim(ajax.responseText).split("#")[1];
					if(TXInfo == "") {
						//alert("<%=SystemEnv.getHtmlLabelName(125567, user.getLanguage())%>");
						return;
					} else {
						$GetEle(_field_vacationInfo).style.display = "none";
		                jQuery("#"+_field_vacationInfo+"span").html(TXInfo);
						jQuery("#"+_field_vacationInfo).val(TXInfo);
					}
				}catch(e){
					//alert("<%=SystemEnv.getHtmlLabelName(125567, user.getLanguage())%>");
					return;
				}
			}
	    }
	}
}
	function showVacationInfo(){
	
		if(_field_vacationInfo == "") return;
		
		var newLeaveType = jQuery("#"+_field_newLeaveType).val();
		var vacationInfoObj = jQuery("input[name='"+_field_vacationInfo+"']");
		var vacationInfoType = vacationInfoObj.attr("type");
		var resourceId = jQuery("input[name='"+_field_resourceId+"']").val();
	
		var result = "";
		if(newLeaveType == '<%=HrmAttVacation.L6%>') {
			getAnnualInfo(resourceId);
		} else if(newLeaveType == '<%=HrmAttVacation.L12%>') {
		    getPSInfo(resourceId);
		} else if(newLeaveType == '<%=HrmAttVacation.L13%>') {
		    getTXInfo(resourceId);
		}else{
		    //$GetEle(_field_vacationInfo).innerText = result;
		    jQuery("#"+_field_vacationInfo+"span").html(result);
			jQuery("#"+_field_vacationInfo).val(result);
		}
	}
	initInfo();
	checkCustomize = function() {
	if( currentnodetype == 0){
			if(workflowid == 115 ) {
				if(vacationcheck115() == 0 ) {//alert("115");
					return false;
				}
			} else {
				if(vacationcheck() == 0) {//alert("其他");
					return false;
				}
			}
		}
		var newLeaveType = jQuery("#"+_field_newLeaveType).val();
		
		if(newLeaveType == '<%=HrmAttVacation.L6%>') {
			if(allannualValue <= 0){
				window.top.Dialog.alert("<%=SystemEnv.getHtmlLabelName(21720,user.getLanguage())%>");
		        return false;
			}
			if($GetEle(_field_leaveDays)!=null && parseFloat($GetEle(_field_leaveDays).value) > parseFloat(realAllannualValue)){
				window.top.Dialog.alert("<%=SystemEnv.getHtmlLabelName(21721,user.getLanguage())%>");
				return false;
			}
		} else if(newLeaveType == '<%=HrmAttVacation.L12%>') {
			if(allpsldaysValue <= 0){
				window.top.Dialog.alert("<%=SystemEnv.getHtmlLabelName(24044,user.getLanguage())%>");
		        return false;
			}
			if($GetEle(_field_leaveDays)!=null && parseFloat($GetEle(_field_leaveDays).value) > parseFloat(realAllpsldaysValue)){
				window.top.Dialog.alert("<%=SystemEnv.getHtmlLabelName(24045,user.getLanguage())%>");
				return false;
			}
		} else if(newLeaveType == '<%=HrmAttVacation.L13%>') {
			if($GetEle(_field_leaveDays)!=null && parseFloat($GetEle(_field_leaveDays).value) > parseFloat(realPaidLeaveDaysValue)){
				window.top.Dialog.alert("<%=SystemEnv.getHtmlLabelName(84604,user.getLanguage())%>");
				return false;
			}
		} 
		
		return true;
	};
	function vacationcheck(){
        var flag = 1;
        var vbegindate = "field5997";//请假开始日期
        var vbegintime = "field5998";//请假开始时间
        var venddate = "field5999";//请假结束日期
        var vendtime = "field6000";//请假结束时间
        var vleavedays = "field6001";//请假天数
        var vleaveType = "field5996";//请假类型

        var begindate = jQuery("#"+vbegindate).val();            
        var begintime1 = jQuery("#"+vbegintime).val();            
        var enddate = jQuery("#"+venddate).val();
        var endtime1 = jQuery("#"+vendtime).val();
        var leavedays = jQuery("#"+vleavedays).val();
		var leaveType = jQuery("#"+vleaveType).val();
		//alert("vacationcheck==" + begindate + "||enddate=" + enddate);
		//alert("begintime1==" + begintime1 + "||endtime1=" + endtime1);

        if(begindate !="" && enddate != "" && begintime1 != "" && endtime1 != "") {
	        var today = new Date();//系统时间
	        var year = today.getFullYear();       //年
	        var month = today.getMonth() + 1;     //月
			if(month < 10) month = "0"+month;
	        var day = today.getDate(); 
	        var hour = today.getHours();
			var minutes = today.getMinutes();           //日
			if(day < 10) day = "0"+day;
	        var todayStr = year+"-"+month+"-"+day;
			if(hour < 10) hour = "0"+hour;
			if(minutes < 10) minutes = "0"+minutes;
			var currenttime = hour+":"+minutes;
			//alert("todayStr=" + todayStr);
			if(leaveType == "-13"){//调休类型的下拉框值
//alert("leaveType ="+leaveType+"||leavedays="+leavedays*24 );
				if((leavedays*8) < 3){
					flag = 0;
					window.top.Dialog.alert("请假天数必须大于等于3小时");
				}
			}
			 //请假开始时间小于请假结束时间
			 if(flag == 1){
				 	var beginD = new Date((begindate + " " + begintime1 + ":00").replace(/-/g,"\/"));
					var endD = new Date((enddate + " " + endtime1 + ":00").replace(/-/g,"\/"));
					//alert("beginD="+beginD+"||endD="+endD);
					if(beginD > endD) {
						flag = 0;
						alert("结束日期早于开始日期，流程不允许提交！");
				}
			 }
//else{		
				if(leavedays%0.5 != 0 && flag == 1) {
					flag = 0;
					window.top.Dialog.alert("请假天数必须是0.5天的整数倍");
				}
			//}

	        //alert("enddate>=todayStr=" + enddate + "||" + todayStr + "||" + (enddate <= todayStr));
			if(((begindate <= todayStr) || (enddate <= todayStr) )&& flag == 1 ) {
				flag = 0;
				window.top.Dialog.alert("请假只能提前一天!");
			}
			if(flag == 1){
				if((begintime1 < "08:30") || (endtime1 > "17:00")) {
					flag = 0;
					window.top.Dialog.alert("请假流程时间为8:30-17:00，其他时间不允许提交！");
				}
			}
        }
		return flag;
   }

   function vacationcheck115(){
        var flag = 1;
        var vbegindate = "field5997";//请假开始日期
        var vbegintime = "field5998";//请假开始时间
        var venddate = "field5999";//请假结束日期
        var vendtime = "field6000";//请假结束时间
        var vleavedays = "field6001";//请假天数
        var vleaveType = "field5996";//请假类型
        var begindate = jQuery("#"+vbegindate).val();            
        var begintime = jQuery("#"+vbegintime).val();            
        var enddate = jQuery("#"+venddate).val();
        var endtime = jQuery("#"+vendtime).val();
        var leavedays = jQuery("#"+vleavedays).val();
		var leaveType = jQuery("#"+vleaveType).val();
        if(begindate !="" && enddate != "" && begintime != "" && endtime != "") {
        	var begindateYear = begindate.substring(0,4)*1;
	        var enddateYear = enddate.substring(0,4)*1;
			var begindateMonth = begindate.substring(5,7)*1;
			var enddateMonth = enddate.substring(5,7)*1;
			//alert(begindateYear+"||"+begindateMonth);
			//alert(enddateYear+"||"+enddateMonth);
			var today = new Date();
	        var year = today.getFullYear();
	        var month = today.getMonth() + 1;
			var date = today.getDate();
			var monthStr = month;
			var hour = today.getHours();
			var minutes = today.getMinutes();
			if(month < 10) monthStr = "0"+monthStr;
			if(date < 10) date = "0"+date;
			if(hour < 10) hour = "0"+hour;
			if(minutes < 10) minutes = "0"+minutes;
			var currentdate = year+"-"+monthStr+"-"+date;
			var currenttime = hour+":"+minutes;
			//alert(year+"||"+month+"||"+date);		
			//if((begindateYear == year && begindateMonth == month) && (enddateYear == year && enddateMonth == month)) {
			if(leaveType == "-13"){
				if((leavedays*8) < 3){
					flag = 0;
					window.top.Dialog.alert("请假天数必须大于等于3小时");
				}
			}

			 if(leavedays%0.5 != 0 && flag == 1) {
					flag = 0;
					alert("请假天数必须是0.5天的整数倍");
				} 
			 
			 //请假开始时间小于请假结束时间
			 if(flag == 1){
				 	var beginD = new Date((begindate + " " + begintime + ":00").replace(/-/g,"\/"));
					var endD = new Date((enddate + " " + endtime + ":00").replace(/-/g,"\/"));
					//alert("beginD="+beginD+"||endD="+endD);
					if(beginD > endD) {
						flag = 0;
						alert("结束日期早于开始日期，流程不允许提交！");
				}
			 }
			 
			if(flag == 1){
					//alert("begindate="+begindate+"&begintime="+begintime+"&enddate="+currentdate+"&endtime="+currenttime);
					var ajax=ajaxInit();
					ajax.open("POST", "/proj/process/GetWorkDays.jsp", false);
					ajax.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
					ajax.send("begindate="+begindate+"&begintime="+currenttime+"&enddate="+currentdate+"&endtime="+currenttime);
	          		try{
	          			var workdays=trim(ajax.responseText)*1;
						//alert("workdays==" + workdays);
						if(workdays < 0) {
							alert("不允许提前申请!");
							flag =  0;
						} 
						/*else if(workdays > 2){
							alert("不能补2个工作日之前的请假!");
							flag =  0;
						}*/
	          		}catch(e){
	        			alert("请假日期判断异常!请关闭后重试!");
	        			flag =  0;
	        		}

					var resourceId = jQuery("input[name='"+_field_resourceId+"']").val();
					ajax.open("POST", "/workflow/request/BillBoHaiLeaveXMLHTTP.jsp", false);
					ajax.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
					ajax.send("operation=getHrmLeaveTimeInOneMonth&resourceID="+resourceId+"&fromDate="+begindate);
					try{
	          			var oneMonthTimes=trim(ajax.responseText);
						//alert("oneMonthTimes==" + oneMonthTimes);
						if(oneMonthTimes == "3") {
							alert("当前月已补三次!不允许提交申请!");
							flag =  0;
						}
	          		}catch(e){
	        			alert("每人每月不能超过3次判断异常!请关闭后重试!");
	        			flag =  0;
	        		}
				}
		/*	} else {
				alert("补请假必须当月");
				flag =  0;
			}*/
        }
        if(flag == 1){
			if((begintime < "08:30") || (endtime > "17:00")) {
			//alert("begintime="+begintime+"||endtime="+endtime);
				flag = 0;
				window.top.Dialog.alert("请假流程时间为8:30-17:00，其他时间不允许提交！");
			}
		}
		return flag;
   }
</script>
