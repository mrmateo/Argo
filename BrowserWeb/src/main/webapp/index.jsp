<html>
<head>
  <meta http-equiv="content-type" content="text/html; charset=utf-8">
  <title>DI2E RTSD Browser</title>

  <link rel="stylesheet" href="http://code.jquery.com/ui/1.9.1/themes/base/jquery-ui.css">
  <script src="//ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js" type="text/javascript"></script>
  <script src="//ajax.googleapis.com/ajax/libs/jqueryui/1/jquery-ui.min.js" type="text/javascript"></script>
  
  <link href='http://fonts.googleapis.com/css?family=Josefin+Sans:600|Varela|Hammersmith+One|Indie+Flower|Karla|Orbitron' rel='stylesheet' type='text/css'>
 
  <link href="js/jquery.fancytree/skin-win8/ui.fancytree.css" rel="stylesheet" type="text/css">
  <script src="js/jquery.fancytree/jquery.fancytree.js" type="text/javascript"></script>
  <style>
  	ul.fancytree-container { font-size: 12pt }
  	span.fancytree-title { font-family: 'Karla', sans-serif; font-size: 14pt; }
  	div.service-details { font-family: 'Karla', serif; font-size: 15pt; }
  	td.detail-key { font-family: 'Orbitron', sans-serif; background-color: rgb(199, 213, 213); padding: 3px 25px; font-weight: bold }
  	td.detail-data { font-family: 'Karla', sans-serif; font-size: 14pt; padding: 0 }
  	a.detail-data { font-family: 'Karla', sans-serif; font-size: 14pt; padding: 0 }
  	.ui-button-text { font-family: 'Orbitron', sans-serif; }
    .ui-tabs { font-family: 'Orbitron', sans-serif; }
  </style>

<script type="text/javascript">

	var services;
	var byContract;
	var serviceList;

  $(function(){
    initTree();

    $("#refreshButton").button().click(function(event) { refresh(); });
    $("#probeButton").button().click(function(event) { launchProbe(); });
    $( "#tabs" ).tabs();
    $("#clearButton").button().click(function(event) { clearCache(); });

    getServices();
    
  });


  function launchProbe() {
	  $.ajax({
		  url: "/BrowserWeb/api/controller/launchProbe",
		  data: { },
		  success: function( data ) {
			  alert("Response: " + data);
		  },
		  error: function ( data ) { alert("failed"); }
		});


	  }

  function refresh() {

	  getServices();
	  }

  function getContracts() {
	  $.ajax({
		  url: "/AsynchListener/api/responseHandler/contracts",
		  data: { },
		  success: function( data ) {
			  alert("got contracts: " + data);
			  var newSource = [];

			  for (var contract in data.contracts) {
				newSource.push({"title": contract.contractDescription, "key" : contract.contractID});

				  };

			  byContract.source(newSource);
		  }
		});


	  };

  function clearCache() {
	  $.ajax({
		  url: "/AsynchListener/api/responseHandler/clearCache",
		  data: { },
		  success: function( data ) {
			 refresh();
		  },
		  fail: function(data) {
			  alert(data);
		  }
		});


	  };
		  
  function getServices() {
	  $.ajax({
		  url: "/AsynchListener/api/responseHandler/responses",
		  data: { },
		  success: function( data ) {
			  //alert("got services");
			  
			  $("#serviceTable1").html("");
			  
			  var i;
			  var newSource = [];

			  var contractIDMap = {};
			  for(i = 0; i < data.cache.length; i++) {
				  var service = data.cache[i];
				  var contract = contractIDMap[service.serviceContractID];
				  if (!contract) {
					  contract = { "contractID" : service.serviceContractID,
							  "contractDescription" : service.contractDescription, "services" : []};
					  contractIDMap[service.serviceContractID] = contract;
					  }
				  contract.services.push(service);
			  }

			  var s;
			  for (key in contractIDMap) {
				  contract = contractIDMap[key];
				  var contractSource = { "title" : contract.contractDescription, "key" : contract.contractID, "folder" : true, "children" : []};
				  for (s = 0; s < contract.services.length; s++) {
					  var service = contract.services[s];
					  contractSource.children.push({"title": service.serviceName + " : " + service.consumability, "key" : service.id, "data" : service});
					  
					  };
				  newSource.push(contractSource);

				  }

			  $("#byContract").fancytree("option", "source",  newSource );
			  

			  newSource = [];
			  

			  for(i = 0; i < data.cache.length; i++) {
				  var service = data.cache[i];
 				  newSource.push({"title": service.serviceName + " : " + service.consumability, "key" : service.id, "data" : service});
				  };

				  $("#serviceList").fancytree("option", "source",  newSource );
			  
		  }
		});



	  };

  function renderServiceInTable(service, table) {
	  
	  	var row = $("<tr />");
	  	table.append(row); //this will append tr element to table... keep its reference for a while since we will add cels into it
	    row.append($("<td align='right' class='detail-key'>Service ID</td>"));
	    row.append($("<td class='detail-data'>" + service.id + "</td>"));

	  	var row = $("<tr />");
	  	table.append(row); //this will append tr element to table... keep its reference for a while since we will add cels into it
	    row.append($("<td align='right' class='detail-key'>Service Name</td>"));
	    row.append($("<td class='detail-data'>" + service.serviceName + "</td>"));

	  	var row = $("<tr />");
	  	table.append(row); //this will append tr element to table... keep its reference for a while since we will add cels into it
	    row.append($("<td align='right' class='detail-key'>Service Description</td>"));
	    row.append($("<td class='detail-data'>" + service.description + "</td>"));

	  	var row = $("<tr />");
	  	table.append(row); //this will append tr element to table... keep its reference for a while since we will add cels into it
	    row.append($("<td align='right' class='detail-key'>Consumability</td>"));
	    row.append($("<td class='detail-data'>" + service.consumability + "</td>"));

	  	var row = $("<tr />");
	  	table.append(row); //this will append tr element to table... keep its reference for a while since we will add cels into it
	    row.append($("<td align='right' class='detail-key'>Contract ID</td>"));
	    row.append($("<td class='detail-data'>" + service.serviceContractID + "</td>"));

	  	var row = $("<tr />");
	  	table.append(row); //this will append tr element to table... keep its reference for a while since we will add cels into it
	    row.append($("<td align='right' class='detail-key'>Contract Description</td>"));
	    row.append($("<td class='detail-data'>" + service.contractDescription + "</td>"));

	  	var row = $("<tr />");
	  	table.append(row); //this will append tr element to table... keep its reference for a while since we will add cels into it
	    row.append($("<td align='right' class='detail-key'>IP Address</td>"));
	    row.append($("<td class='detail-data'>" + service.ipAddress + "</td>"));

	  	var row = $("<tr />");
	  	table.append(row); //this will append tr element to table... keep its reference for a while since we will add cels into it
	    row.append($("<td align='right' class='detail-key'>Port</td>"));
	    row.append($("<td class='detail-data'>" + service.port + "</td>"));

	  	var row = $("<tr />");
	  	table.append(row); //this will append tr element to table... keep its reference for a while since we will add cels into it
	    row.append($("<td align='right' class='detail-key'>URL</td>"));
		if (service.consumability == "HUMAN_CONSUMABLE") {
			row.append($("<td class='detail-data'><a href='" + service.url + "'>" + service.url + "</td>"));
		} else {
			row.append($("<td class='detail-data'>" + service.url + "</td>"));
		}
	  	

	  	var row = $("<tr />");
	  	table.append(row); //this will append tr element to table... keep its reference for a while since we will add cels into it
	    row.append($("<td align='right' class='detail-key'>TTL</td>"));
	    row.append($("<td class='detail-data'>" + service.ttl + "</td>"));
	    
	  	var row = $("<tr />");
	  	table.append(row); //this will append tr element to table... keep its reference for a while since we will add cels into it
	    row.append($("<td align='right' class='detail-key'>Data</td>"));
	    row.append($("<td class='detail-data'>" + service.data + "</td>"));
	    
	  }
	  

  function initTree() {
	$("#byContract").fancytree({
	      checkbox: false,
	      selectMode: 2,
	      source: [],
	      activate: function(event, data) {
		      if (data.node.data.serviceName) {
		         //alert("selected " + data.node.data.serviceName);
		         $("#serviceTable1").html("");
		         renderServiceInTable(data.node.data, $("#serviceTable1"));
		      } else {
		    	  $("#serviceTable1").html("");
			      }
	        }
	    });
	 $("#serviceList").fancytree({
	      checkbox: false,
	      selectMode: 3,
	      source: [],
	      activate: function(event, data) {
		      if (data.node.data.serviceName) {
		         //alert("selected " + data.node.data.serviceName);
		         $("#serviceTable2").html("");
		         renderServiceInTable(data.node.data, $("#serviceTable2"));
		      } else {
		    	  $("#serviceTable2").html("");
			      }
	        }
	      
	    });
		  
	  };
</script>

 </head>
<body>



	<div class="intro">
		<div id="header">
			<table style="width: 100%">
			 <tr><td><a href="http://devtools.di2e.net" target="_blank"><img alt="" src="images/framework.png"\></a></td><td align="left"><p style="font-family: 'Josefin Sans', sans-serif; font-weight 600; font-size: 40pt">Runtime Service Discovery Browser</p></td></tr>
			</table>
			
			
		</div>
		
		<!-- The name attribute is used by tree.serializeArray()  -->
		<div>
			<button id="refreshButton">Refresh List</button>
			<button id="probeButton">Launch Probe</button>
			<button id="clearButton">Clear Cache</button>
		</div>
		<div id="tabs">
			<ul>
				<li><a href="#tabs-1">Services by Contract</a></li>
				<li><a href="#tabs-2">Plain Service List</a></li>
			</ul>
			<div id="tabs-1">
				<div id="byContract" name="selNodes"></div>
				<fieldset style="margin-top: 20px;">
					<legend>Service Details</legend>
					<div class="service-details" id="serviceDetails1">
						<table id="serviceTable1"></table>
					</div>
				</fieldset>
			</div>
			<div id="tabs-2">
				<div id="serviceList" name="selNodes2"></div>
				<fieldset style="margin-top: 20px;">
					<legend>Service Details</legend>
					<div class="serviceDetails" id="serviceDetails2" style='background-color: white'>
						<table id="serviceTable2"></table>
					</div>
				</fieldset>
			</div>
		</div>

	</div>




</body>
</html>
