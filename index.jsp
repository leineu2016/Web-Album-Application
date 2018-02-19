<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Assignment2</title>
</head>
<body>
	<h1>Upload images to S3</h1>
	<form ENCTYPE="multipart/form-data" ACTION="uploadToS3.jsp" METHOD=POST>
		<p>
			<label for="image">Choose an image:&nbsp;</label> <input type="file"
				name="image" id="image"/>
		</p>
		<p>
			<label for="description">Description of the image:&nbsp;</label> <input
				type="text" name="description" id="description" />
		</p>
		<input type="submit" value="Upload" />
	</form>
</body>
</html>