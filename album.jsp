<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="java.io.ByteArrayInputStream,java.io.File,java.util.List,com.amazonaws.auth.AWSCredentials,com.amazonaws.auth.BasicAWSCredentials,com.amazonaws.util.StringUtils,com.amazonaws.services.s3.AmazonS3,com.amazonaws.services.s3.AmazonS3Client,com.amazonaws.services.s3.model.Bucket,com.amazonaws.services.s3.model.CannedAccessControlList,com.amazonaws.services.s3.model.GeneratePresignedUrlRequest,com.amazonaws.services.s3.model.GetObjectRequest,com.amazonaws.services.s3.model.ObjectListing,com.amazonaws.services.s3.model.ObjectMetadata,com.amazonaws.services.s3.model.S3ObjectSummary,com.amazonaws.ClientConfiguration,com.amazonaws.Protocol,java.sql.Connection,java.sql.DriverManager,java.sql.SQLException,java.sql.Statement,java.sql.ResultSet,java.util.Map,java.util.HashMap"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Assignment2</title>
</head>
<body>
	<h1>The list of images</h1>
	<%
	    Map<String, String> imageDescMap = new HashMap<String, String>();
	    Connection conn = null;
	    Statement stmt = null;
	    ResultSet rs = null;
	    try
	    {
	        Class.forName("com.mysql.jdbc.Driver").newInstance();

	        String URL = "mydbinstance.cqkbowbsli8e.ap-southeast-2.rds.amazonaws.com:3306";//RDS
	        String lURL = "localhost";//local 
	        conn = DriverManager.getConnection("jdbc:mysql://" + URL + "/aws", "s100054418", "Zhyj0121++");
	        stmt = conn.createStatement();

	        rs = stmt.executeQuery("SELECT photo_name, photo_desc from DESCRIPTION;");
	        String photoName;
	        String photoDesc;
	        while (rs.next())
	        {
	            photoName = rs.getString("photo_name");
	            photoDesc = rs.getString("photo_desc");
	            if (photoDesc != null && !photoDesc.isEmpty())
	            {
	                imageDescMap.put(photoName, photoDesc);
	            }
	        }

	    }
	    catch (SQLException ex)
	    {
	        System.out.println("SQLException: " + ex.getMessage());
	        System.out.println("SQLState: " + ex.getSQLState());
	        System.out.println("VendorError: " + ex.getErrorCode());
	%><Br>
	<h2>Cannot connect to the RDS. The description of images cannot be
		displayed.</h2>
	<p>
		<%
		    }
		    finally
		    {
		        if (rs != null)
		        {
		            try
		            {
		                rs.close();
		            }
		            catch (SQLException sqlEx)
		            {
		            }

		            rs = null;
		        }

		        if (stmt != null)
		        {
		            try
		            {
		                stmt.close();
		            }
		            catch (SQLException sqlEx)
		            {
		            }

		            stmt = null;
		        }

		        if (conn != null)
		        {
		            try
		            {
		                conn.close();
		            }
		            catch (SQLException sqlEx)
		            {
		            }

		            conn = null;
		        }
		    }

		    AmazonS3 client = new AmazonS3Client(
		            new BasicAWSCredentials("AKIAI4H3FBXNAR4UVLWQ", "9dKEbqexQ6/kNH2BKLCSszr5h+d7K8Dx0siDWjUk"));
		    ObjectListing objects = client.listObjects("zhyj0121pp");
		    String imageName;
		    String imageDesc;
		    do
		    {
		        for (S3ObjectSummary objectSummary : objects.getObjectSummaries())
		        {
		            imageName = objectSummary.getKey();
		            imageDesc = imageDescMap.get(imageName);
		            if (imageDesc == null)
		            {
		                imageDesc = "";
		            }
		%>
	
	<p>
		<label><%=imageName%>.</label><br /> <label>Description: <%=imageDesc%></label><br />
		<img alt="<%=imageName%>"
			src="<%=client.generatePresignedUrl(new GeneratePresignedUrlRequest("zhyj0121pp", imageName))%>">
	</p>
	<br />
	<%
	    }
	        objects = client.listNextBatchOfObjects(objects);
	    }
	    while (objects.isTruncated());
	%>
</body>
</html>