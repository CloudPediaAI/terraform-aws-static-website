resource "aws_s3_object" "index_html" {
  count = (var.website_source_folder == null) ? 1 : 0

  depends_on   = [aws_s3_bucket.root]
  bucket       = local.bucket_name
  key          = "index.html"
  content      = "<!DOCTYPE html><html lang='en'><head><meta charset='UTF-8'><meta name='viewport' content='width=device-width,initial-scale=1.0'><title>Coming Soon</title><style>body{font-family:sans-serif;margin:0;padding:0;background-color:#84c98a} .container{max-width:800px;margin:0 auto;padding:20px} .header{text-align:center;color:#f1eaea;font-size:2em;margin-bottom:20px} .content{color:#025b6b;line-height:1.5} .footer{text-align:center;color:#3b3a3a;margin-top:20px}</style></head><body><div class='container'><div class='header'><h1>Something amazing is coming soon!</h1></div><div class='content'><p>Get ready for something brand new and exciting.  We are working hard to bring you a breaking through experience.  Stay tuned for more updates!</p></div><div class='footer'><p>Template created by CloudPedia.AI</p></div></div></body></html>"
  content_type = "text/html"
}

resource "aws_s3_object" "error_html" {
  count = (var.website_source_folder == null) ? 1 : 0

  depends_on   = [aws_s3_bucket.root]
  bucket       = local.bucket_name
  key          = "error.html"
  content      = "<!DOCTYPEhtml><html lang='en'><head><meta charset='UTF-8'><meta name='viewport' content='width=device-width,initial-scale=1.0'><title>Oops! Page Not Found</title><style>body{font-family:sans-serif;margin:0;padding:0;background-color:#ff7c7c} .container{max-width:800px;margin:0 auto;padding:20px;text-align:center} .header{text-align:center;color:#f1eaea;font-size:2em;margin-bottom:20px} .error-message{margin-bottom:20px} .error-message p{font-size:1.2em;color:#666} .navigation{margin-top:20px} .navigation ul{list-style:none;padding:0} .navigation li{margin-bottom:10px} .navigation a{text-decoration:none;color:#333} .navigation a:hover{text-decoration:underline} .footer{text-align:center;color:#3b3a3a;margin-top:20px}</style></head><body><div class='container'><div class='header'><h1>404: Page Not Found</h1></div><div class='error-message'><p>The page you are looking for does not seem exist anymore.</p></div><div class='navigation'><h2>Let's get you back on track!</h2><ul><li><a href='/'>Goto the homepage</a></li></ul></div><div class='footer'><p>Template cre ated by CloudPedia.AI</p></div></div></body></html>"
  content_type = "text/html"
}
