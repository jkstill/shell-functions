
# example
# body of email is in ~/zips/test.txt
# the last argument is an attachment
# email_attachment jkstill@gmail.com,still@pythian.com still@pythian.com "email test" ~/zips/test.txt  ~/zips/rman-chk-new.tgz


email_attachment() {
	to="$1"
	cc="$2"
	subject="$3"
	bodyfile="$4"
	attachment="${5:-''}"
	boundary="_====_blah_====_$(date +%Y%m%d%H%M%S)_====_"
	{
		printf -- "To: $to\n"
		printf -- "Cc: $cc\n"
		printf -- "Subject: $subject\n"
		printf -- "Content-Type: multipart/mixed; boundary=\"$boundary\"\n"
		printf -- "Mime-Version: 1.0\n"
		printf -- "\n"
		printf -- "This is a multi-part message in MIME format.\n"
		printf -- "\n"
		printf -- "--$boundary\n"
		printf -- "Content-Type: text/plain; charset=ISO-8859-1\n"
		printf -- "\n"
		if [[ -n "$bodyfile" && -f "$bodyfile" && -r "$bodyfile" ]]; then
			cat -- $bodyfile
		else
			printf -- "The file for the body of this email was not found\n"
		fi
		printf -- "\n"
		if [[ -n "$attachment" && -f "$attachment" && -r "$attachment" ]]; then
			attachDir=$(/usr/bin/dirname $attachment)
			attachFile=$(/bin/basename $attachment)
			cd $attachDir
			printf -- "--$boundary\n"
			printf -- "Content-Transfer-Encoding: base64\n"
			printf -- "Content-Type: application/octet-stream; name=$attachFile\n"
			printf -- "Content-Disposition: attachment; filename=$attachFile\n"
			printf -- "\n"
			printf -- "$(/usr/bin/base64 $attachFile)\n"
			printf -- "\n"
		fi
		printf -- "--${boundary}--\n"
	} | /usr/lib/sendmail -oi -t
}

