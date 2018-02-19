<%@ page
	import="java.io.*,com.amazonaws.auth.BasicAWSCredentials,com.amazonaws.services.s3.AmazonS3,com.amazonaws.services.s3.AmazonS3Client,com.amazonaws.services.s3.model.CannedAccessControlList,com.amazonaws.services.s3.model.ObjectMetadata,java.sql.Connection,java.sql.DriverManager,java.sql.SQLException,java.sql.Statement"%>
<%
    String saveFile = "";
    String contentType = request.getContentType();
    if ((contentType != null) && (contentType.indexOf("multipart/form-data") >= 0))
    {
        DataInputStream in = new DataInputStream(request.getInputStream());
        int formDataLength = request.getContentLength();
        byte dataBytes[] = new byte[formDataLength];
        int byteRead = 0;
        int totalBytesRead = 0;
        while (totalBytesRead < formDataLength)
        {
            byteRead = in.read(dataBytes, totalBytesRead, formDataLength);
            totalBytesRead += byteRead;
        }
        String file = new String(dataBytes);

        saveFile = file.substring(file.indexOf("filename=\"") + 10);
        saveFile = saveFile.substring(0, saveFile.indexOf("\n"));
        saveFile = saveFile.substring(saveFile.lastIndexOf("\\") + 1, saveFile.indexOf("\""));
        if (saveFile.equals(""))
        {
%><Br>
<h2>You must choose an image. Please try again.</h2>
<p>
	<a href="index.jsp">Click here to upload an image.</a>
</p>
<%
    return;
        }
        String fileName = saveFile;
        int lastIndex = contentType.lastIndexOf("=");
        String boundary = contentType.substring(lastIndex + 1, contentType.length());
        int pos;
        pos = file.indexOf("filename=\"");
        pos = file.indexOf("\n", pos) + 1;
        pos = file.indexOf("\n", pos) + 1;
        pos = file.indexOf("\n", pos) + 1;
        int startPos = pos;
        int endPos = file.indexOf(boundary, pos) - 4;
        byte[] imageB = new byte[endPos - startPos];
        for (int i = startPos, j = 0; i < endPos; i++, j++)
        {
            imageB[j] = dataBytes[i];
        }

        String bucket = "zhyj0121pp";
        try
        {
            AmazonS3 client = new AmazonS3Client(new BasicAWSCredentials("AKIAI4H3FBXNAR4UVLWQ",
                    "9dKEbqexQ6/kNH2BKLCSszr5h+d7K8Dx0siDWjUk"));
            InputStream stream = new ByteArrayInputStream(imageB);
            ObjectMetadata meta = new ObjectMetadata();
            meta.setContentLength(endPos - startPos);
            meta.setContentType("image/jpeg");
            client.putObject(bucket, fileName, stream, meta);
            client.setObjectAcl(bucket, fileName, CannedAccessControlList.PublicRead);
        }
        catch (Exception ex)
        {
            System.out.println(ex);
%><Br>
<h2>Cannot upload the image to S3. Please try again.</h2>
<p>
	<a href="index.jsp">Click here to upload an image.</a>
</p>
<%
    return;
        }

        String descKey = "name=\"description\"";
        pos = file.indexOf(descKey, pos);
        pos = file.indexOf("\n", pos) + 1;
        pos = file.indexOf("\n", pos) + 1;
        String descValue = file.substring(pos);
        descValue = descValue.substring(0, descValue.indexOf(boundary) - 4);
        String RDS = "aws.cqkbowbsli8e.ap-southeast-2.rds.amazonaws.com:3306";
        Connection conn = null;
        Statement stmt = null;
        try
        {
            Class.forName("com.mysql.jdbc.Driver").newInstance();
            String URL = "mydbinstance.cqkbowbsli8e.ap-southeast-2.rds.amazonaws.com:3306";//RDS
            String lURL = "localhost";//local 
            conn = DriverManager.getConnection("jdbc:mysql://" + URL + "/aws", "s100054418", "Zhyj0121++");
            stmt = conn.createStatement();

            if (0 == stmt.executeUpdate("UPDATE DESCRIPTION SET photo_desc = '" + descValue
                    + "' WHERE photo_name = '" + fileName + "';"))
            {
                stmt.executeUpdate("INSERT INTO DESCRIPTION (photo_name, photo_desc) VALUES('" + fileName
                        + "', '" + descValue + "');");
            }

        }
        catch (SQLException ex)
        {
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());
%><Br>
<h2>Cannot connect to the RDS. Please try again.</h2>
<p>
	<a href="index.jsp">Click here to upload an image.</a>
</p>
<%
    return;
        }

        finally
        {
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
%><Br>
<h2>The image has been uploaded to S3</h2>
<p>
	<a href="album.jsp">Click here to visit the album.</a>
</p>
<%
    }
%>
