<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<!-- Forked Web Design from here: http://win32.libav.org/win64/ -->

<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>Package Submission | ASPDM</title>
		
		<?php include 'header.php'; ?>
		
		<script src="src/jquery-1.11.0.min.js"></script>
		<link rel="stylesheet" href="src/ladda.min.css">
		<script src="src/jquery.form.js"></script>
		<script src="src/spin.min.js"></script>
		<script src="src/ladda.min.js"></script>
		<style>
			.progress {
				top: 8px;
				display:inline-block;
				position:relative;
				width:400px;
				border: 1px solid #ddd;
				padding: 1px;
				border-radius: 3px;
				height:22px;
			}
			.bar {
				background-color: #B4F5B4;
				width:0%;
				border-radius: 3px;
				height:100%;
			}
			.percent {
				position:absolute;
				display:inline-block;
				top:2px;
				text-align: center;
				width: 100%;
			}
		</style>

		<script type="text/javascript">
		</script>
		
	</head>

	<body>
		<div class="container">
			<h1><a href="/" id="logolink"><img id="logo" src="src/ahk.png"> ASPDM - AHKScript.org's Package/StdLib Distribution and Management</h1></a>
			<div id="body">
			
			<div id="headerlinks">
				<?php include 'navmenu.php'; ?>
			</div>

			<h2>Package Submission</h2>

			<div><h4>Upload your package file (.ahkp) :</h4>
				<form action="p_submit.php" method="post" enctype="multipart/form-data">
					<div class="fullw">
						<label for="file">Package:</label>
						<input type="file" name="file" id="file"><br>
						
						<input type="submit" value="Submit Package" class="big">
						<div class="progress" style="display:none;">
							<div class="bar"></div>
							<div class="percent">0%</div>
						</div><br>
						
						<!--
						<button class="ladda-button" data-color="mint" data-style="expand-right" data-size="s">Submit</button>
						<br>
						-->
						<code id="status" style="display:none;"></code>
					</div>
				</form>
				<script type="text/javascript">
					(function() {
						
						var bar = $('.bar');
						var progress = $('.progress');
						var percent = $('.percent');
						var status = $('#status');
						
				        //var bt = Ladda.create( document.querySelector( 'button' ) ); 
						$('form').ajaxForm({
							beforeSend: function() {
								
								progress.css("display","inline-block");
								status.html("Please wait...");
								var percentVal = '0%';
								bar.width(percentVal)
								percent.html(percentVal);
								
								//bt.start();
							},
							uploadProgress: function(event, position, total, percentComplete) {
								
								var percentVal = percentComplete + '%';
								bar.width(percentVal)
								percent.html(percentVal);
								
 								//bt.setProgress( percentComplete/10 );
							},
							success: function() {
								
								var percentVal = '100%';
								bar.width(percentVal)
								percent.html(percentVal);
								//Maybe, during a rainy day, I'll be less lazy than today. And, I will try making the Ladda buttons show a tick when it's done...
							},
							complete: function(xhr) {
							
								status.html(xhr.responseText);
								status.css("display","inline-block");
								
								//bt.stop();
							}
						}); 

					})();
				</script>
				<hr class="max">
			</div>

			<h1>Notice</h1>
				<h4>Submission terms and conditions </h4>
				<p>
				Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed at scelerisque magna, sed hendrerit enim. Aliquam interdum, felis non euismod dignissim, arcu nisi eleifend enim, sed mollis sem sem quis sem. Donec in iaculis quam, sed pretium quam. Donec congue, nunc vitae elementum tempus, nibh neque scelerisque ante, at tempus lacus augue convallis dui. Maecenas vitae elit consequat, volutpat nisl nec, mollis mi. Curabitur non tellus ut enim tristique commodo. Nulla pulvinar tellus augue, eget auctor est euismod nec. Maecenas vestibulum tortor at lacus aliquet, sed rhoncus leo elementum. Aliquam eleifend aliquet odio ut euismod. Morbi volutpat orci in ipsum facilisis, porttitor eleifend ipsum viverra. Nullam quis vehicula nisi.
				</p>
			</div>
			
			<?php include 'footer.php'; ?>
			
		</div>
	</body>
</html>