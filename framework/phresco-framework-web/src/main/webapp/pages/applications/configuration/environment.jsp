<%--
  ###
  Framework Web Archive
  
  Copyright (C) 1999 - 2012 Photon Infotech Inc.
  
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  
       http://www.apache.org/licenses/LICENSE-2.0
  
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  ###
  --%>
<%@ taglib uri="/struts-tags" prefix="s"%>

<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Collection"%>
<%@ page import="java.util.Iterator"%>
<%@ page import="com.photon.phresco.configuration.Environment" %>
<%@ page import="com.photon.phresco.commons.FrameworkConstants"%>

<% 
	String projectCode = (String)request.getAttribute(FrameworkConstants.REQ_PROJECT_CODE);
	String fromTab = (String)request.getAttribute(FrameworkConstants.SETTINGS_FROM_TAB);
   	List<Environment> envInfoValues = (List<Environment>) request.getAttribute(FrameworkConstants.ENVIRONMENTS);
%>

<div class="popup_Modal" style="top: 40%;">
	<div class="modal-header">
		<h3 id="generateBuildTitle">
			<s:text name="label.environment"/>
		</h3>
		<a class="close" href="#" id="close">&times;</a>
	</div>

	<div class="modal-body" style="height: 230px;">
		<div class="clearfix">
			<label for="xlInput" class="xlInput popup-label" ><span class="red">*</span> <s:text name="label.name"/></label>
			<div class="input">
				<input type="text" id="envName" name="envName" tabindex=1 class="xlarge" maxlength="30" title="30 Characters only">	
			</div>
		</div>
		<div class="clearfix">
			<label for="xlInput" class="xlInput popup-label"><s:text name="label.description"/></label>
			<div class="input">
				<textarea id="envDesc" class="xlarge env-desc" tabindex=2 maxlength="150" title="150 Characters only"></textarea>
				<input type="button" value="Add" tabindex=3 id="Add" class="primary btn" style="margin-top: 36px;">
			</div>
		</div>
		<form id="environment" method="post" autocomplete="off">
			<fieldset class="popup-fieldset" style="height: 115px;">
				<legend class="fieldSetLegend" ><s:text name="label.added.environment"/></legend>
				<select name="selectedEvn" id="selectedEvn" tabindex=4 class="xlarge" multiple="multiple" style="height: 88px; width: 300px; float: left; margin-left: 100px;" >
					<%
						 for(Environment env : envInfoValues ) {
					%>
	                	   <option value="<%= env.getName() %>" title="<%= env.getDesc() %>" <%= env.isDefaultEnv() ? "disabled" : ""%> id="created"><%= env.getName() %></option>
		            <% 
				       }
		            %>
				</select>
				<div style="float: left; margin-left: 5px;">
					<img src="images/icons/top_arrow.png" title="Move up" id="up" style="cursor: pointer;"><br>
					<img src="images/icons/delete(1).png" title="Remove" id="remove" style="cursor: pointer; margin-top: 20px;"><br>
					<img src="images/icons/btm_arrow.png" title="Move down" id="down" style="cursor: pointer; margin-top: 16px;" >
				</div>
				<div id="setAsDefaultDiv" style="float: right; margin-right: 35px;">
				    <input type="button" value="Set as Default" tabindex=5 id="setAsDefault" class="primary btn" style="margin-top: 30px;">
				</div>
			</fieldset>
		</form>
	</div>
	
	<div class="modal-footer">
		<div class="action popup-action">
		    <input type="button" class="btn primary" value="<s:text name="label.cancel"/>" id="cancel" tabindex=7>
            <input type="button" class="btn primary" value="<s:text name="label.save"/>" id="save" tabindex=6>
            
			<div id="errMsg" class="envErrMsg"></div>
			<div id="reportMsg" class="envErrMsg"></div>
<!-- 			error and success message -->
			<div class="popup alert-message success" id="popupSuccessMsg"></div>
			<div class="popup alert-message error" id="popupErrorMsg"></div>
		</div>
	</div>
</div>
<!-- selectedEnvs hidden field will be updated with the newly added environments after clicking the Add button -->
<input type="hidden" id="selectedEnvs" name="selectedEnvs" value="">
<input type="hidden" id="deletableItems" name="deletableItems" value="">
<script type="text/javascript">
	escPopup();
	
	var name =  "";
	var desc =  "";
	var deletableEnvs = "";
	var deletableItems = "";
	$(document).ready(function() {
		
		if(<%= "settings".equals(fromTab) %>) {
			$('#setAsDefaultDiv').hide();
		}
		
		$("#envName").focus();
		
		$('#close, #cancel').click(function() {
			showParentPage();
		});
		
		//To add the entered values into the selectbox
		$("#Add").click(function() {
			emptyMessages();
			
			var returnVal = true;
			name =($.trim($("#envName").val()));
			desc = $("#envDesc").val();
			if(name == "") {
				$("#errMsg").html("<s:text name='enter.environment.name'/>");
				$("#envName").focus();
				$("#envName").val("");
				returnVal = false;
			} else {
				$("#selectedEvn option").each(function() {
					if (name.trim().toLowerCase() == $(this).val().trim().toLowerCase()) {
						$("#errMsg").html("<s:text name='environment.name.already.exists'/>");
						returnVal = false;
						return false;
					}
				});				
			}
			
			if (returnVal) {
				validateEnv(name, desc);				
			}
		});
		  
		
         $("#setAsDefault").click(function() {
        	 $('#errMsg').html('');
             var setAsDefaultEnvsSize = $('#selectedEvn option:selected').size();
             if (setAsDefaultEnvsSize < 1 || setAsDefaultEnvsSize > 1) {
            	 $("#errMsg").html("<s:text name='please.select.one.environment'/>");
            	 return false;
             }
             
             var setAsDefaultEnvs = new Array();
             $('#selectedEvn option:selected').each( function() {
            	 setAsDefaultEnvs.push($(this).val());
             });
             
             var params = "";
             if (!isBlank($('form').serialize())) {
                 params = $('form').serialize() + "&";
             }
             params = params.concat("setAsDefaultEnv=");
             params = params.concat(setAsDefaultEnvs.join(","));           
             performAction('setAsDefault', params, '', true); 
        });
		
       //To remove the entered value
         $('#remove').click(function() {
	         var deletetableEnvsArr = new Array();
	         deletableItems = "";
	         var nameSep = new Array();
	         var hiddenFieldVal = $("#selectedEnvs").val();
	         nameSep = hiddenFieldVal.split("#SEP#");
	         var finalValue = "";
	
			//deleting environment array
			var nameSepDelArr = new Array();
			//deleting option in select box
			var optionDelArr = new Array();
			
	         // To remove the Environments from the list box which is not in the XML
	         $('#selectedEvn option:selected').each( function() {
		         var currentVal = $(this).val(); // selected option
		         for(var i=0; i < nameSep.length; i++) {
		        	 if (nameSep[i] != "" && nameSep[i] != undefined) {
		        		 var avail = nameSep[i].split("#DSEP#")[0] == currentVal;
					     if(avail) {
					    	 nameSepDelArr.push(nameSep[i]);
					    	 optionDelArr.push($(this).val());
					     } 
				     }
		         }
		         deletetableEnvsArr.push(currentVal);
		         $("#selectedEnvs").val(finalValue);
	         });
	         
	        // remove added value , which deleted as soon as it is added
	        //nameSep will have the newly added value
	 		$.each(nameSepDelArr, function(key, nameSepDelvalue) {
				if (nameSepDelvalue != "" && nameSepDelvalue != undefined) {
	  				$.each(nameSep, function(key, nameSepvalue) {
	  					if (nameSepDelvalue == nameSepvalue) {
	  						delete nameSep[key];
	  					}
	  				});
				}
			});

	 		// after user removed from UI, updated in hiddenfield in above stmt and removing option
	 		$.each(optionDelArr, function(key, delOptionvalue) {
				$("#selectedEvn option[value='"+ delOptionvalue +"']").remove();
				//remove these values from  deletetableEnvsArr which is having all the values that are selected for removal
				//we removed locally added items. the items which are available in xml need to be deleted from thi variable
				$.each(deletetableEnvsArr, function(key, deletableEnvs) {
  					if (delOptionvalue == deletableEnvs) {
  						delete deletetableEnvsArr[key];
  					}
  				});
			});
	 		
	 		// make comma separated value here
	 		// environment selected for deletion , the environmet that are available in xml values 
	 		$.each(deletetableEnvsArr, function(key, deletableEnvs) {
	 			if (deletableEnvs != "" && deletableEnvs != undefined) {
	 				deletableItems = deletetableEnvsArr.join(",");
	 			}
	 		});

	 		// final value is the value that need to be updated in hidden field , it specifies newly added env is popup
	 		$.each(nameSep, function(key, nameSepvalue) {
  				if (nameSepvalue != "" && nameSepvalue != undefined) {
  					finalValue = finalValue + nameSepvalue + "#SEP#";
  				}
	  		});
	 		$("#selectedEnvs").val(finalValue);// this value used in saving envs, That are added
	        validateRemove(deletableItems);
         });
		
		//To move up the values
		$('#up').bind('click', function() {
			$('#selectedEvn option:selected').each( function() {
				var newPos = $('#selectedEvn  option').index(this) - 1;
				if (newPos > -1) {
					$('#selectedEvn  option').eq(newPos).before("<option value='"+$(this).val()+"' selected='selected'>"+$(this).text()+"</option>");
					$(this).remove();
				}
			});
		});
		
		//To move down the values
		$('#down').bind('click', function() {
			var countOptions = $('#selectedEvn option').size();
			$('#selectedEvn option:selected').each( function() {
				var newPos = $('#selectedEvn  option').index(this) + 1;
				if (newPos < countOptions) {
					$('#selectedEvn  option').eq(newPos).after("<option value='"+$(this).val()+"' selected='selected'>"+$(this).text()+"</option>");
					$(this).remove();
				}
			});
		});
		
		$("#save").click(function() {
			emptyMessages();
			
			var envs = $("#selectedEnvs").val();
			var deletableData = $('#deletableItems').val();
           	if(deletableData == "" ) {
           		if(envs == "") {
	                $("#errMsg").html("Add Environments");
	            } else {
	            	generateXML(envs, deletableData);
	            }
           	} else {
           		generateXML(envs, deletableData);
           	}
        });
		
		$("#envName").bind('input propertychange',function(e){ 	//envName validation
	     	var name = $(this).val();
	     	name = checkForSplChr(name);
	     	$(this).val(name);
		});
	});

	function generateXML(envs, deletableData) {
		var url = "";
		var conatiner = "";
		if(<%= "settings".equals(fromTab) %>) {
			url = "createSettingsEnvironment";
			conatiner = $("#container");
		}
		else {
			url = "createEnvironment";
			conatiner = $("#tabDiv");
		}
        showParentPage();
       	var params = "";
		if (!isBlank($('form').serialize())) {
			params = $('form').serialize() + "&";
		}
		if (envs != undefined  && envs != "") {
			params = params.concat("envs=");
			params = params.concat(envs);			
		}
		if (deletableData != undefined && deletableData != "") {
			if (envs != undefined  && envs != "") {
				params = params.concat("&deletableEnvs=");
			} else {
				params = params.concat("deletableEnvs=");
			}
			params = params.concat(deletableData);
		}
		performAction(url, params, conatiner);
    }
	
	function validateEnv(envs, desc) {
       	var params = "";
		if (!isBlank($('form').serialize())) {
			params = $('form').serialize() + "&";
		}
		params = params.concat("envs=");
		params = params.concat(envs);
		if(<%= "settings".equals(fromTab) %>) {
		    performAction('checkDuplicateEnvSettings', params, '', true);
		} else {
			performAction('checkDuplicateEnv', params, '', true);	
		}
	}
	
	function successValidateEnv(data) {
    	if(data.envError == undefined) {
    		$("#errMsg").empty();
    		var hiddenFieldVal = $("#selectedEnvs").val();
			hiddenFieldVal = hiddenFieldVal + name + "#DSEP#" + desc + "#SEP#";
			$('#selectedEnvs').val(hiddenFieldVal);
			$("#selectedEvn").append($("<option></option>").attr("value", name).attr("title", desc).text(name));
			$("#envName").val("");
			$("#envDesc").val("");
		} else {
		    $("#errMsg").html(data.envError);
		}
	}
	
	function emptyEnvVal(evt) {
		var evt = (evt) ? evt : ((event) ? event : null);
		var node = (evt.target) ? evt.target : ((evt.srcElement) ? evt.srcElement : null);
		if ((evt.keyCode == 13) && (node.type=="text"))  {return false;}
	}

	document.onkeypress = emptyEnvVal; 
	
	function successEvent(pageUrl, data) {
		if (pageUrl == "checkDuplicateEnvSettings" || pageUrl == "checkDuplicateEnv") {
			successValidateEnv(data);
		}
		if (pageUrl == "checkForRemoveSettings" || pageUrl == "checkForRemove" || pageUrl == "setAsDefault") {
			emptyMessages();
			
			if (data.envError != undefined) {
                //when setting a default , after successfull operation , it will come here
                if(data.flag && pageUrl == "setAsDefault") {
                    setDefaultAsDisable();
                    $("#reportMsg").html(data.envError);
                } else {
                    $("#errMsg").html(data.envError);
                    deletableItems = "";
                }
			} else {
				$("#errMsg, #reportMsg").html("");
				var availDeletableItems = $("#deletableItems").val();
				if(availDeletableItems == ""){
					availDeletableItems = availDeletableItems + deletableItems;
				} else {
					availDeletableItems = availDeletableItems + "," + deletableItems;
				}
				
				$('#deletableItems').val(availDeletableItems);
				var deletableData = $('#deletableItems').val();  // This is for removing data from popup 
				var deleteThis = new Array();
				deleteThis = deletableData.split(",");
				for (deletableEnv in deleteThis ) {
					$("#selectedEvn option[value='" + deleteThis[deletableEnv] + "']").remove();
				}
			}
		}
	}
	
	function emptyMessages() {
		$("#errMsg, #reportMsg").html("");
	}
	
	function setDefaultAsDisable() {
         $('#selectedEvn option').each( function() {
        	$(this).prop('disabled', false);
         });
         
         $('#selectedEvn option:selected').prop('disabled', true);
         $('#selectedEvn option:selected').prop('selected', false);
	}	
	
	function validateRemove(deletableItems) {
       	var params = "";
		if (!isBlank($('form').serialize())) {
			params = $('form').serialize() + "&";
		}
		params = params.concat("deletableEnvs=");
		params = params.concat(deletableItems);
		if(<%= "settings".equals(fromTab) %>) {
		    performAction('checkForRemoveSettings', params, '', true);
		} else {
			performAction('checkForRemove', params, '', true);	
		}
	}
</script>