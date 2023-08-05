## Java docker image with custom JRE and SSL certificate
[[jvm]]

	# base image to build a JRE	
	FROM amazoncorretto:17.0.3-alpine as corretto-jdk
		  
	# required for strip-debug to work	
	RUN apk add --no-cache binutils		
	
	# Build a small JRE image	
	RUN $JAVA_HOME/bin/jlink \	
	         --verbose \	
	        --add-modules java.base, java.management, java.naming,java.net.http, \	
	                                   java.security.jgss, java.security.sasl,java.sql,jdk.httpserver, jdk.unsupported \	
	         --strip-debug \	
	         --no-man-pages \	
	         --no-header-files \	
	         --compress=2 \	
	         --output /customjre
		  
	# main app image	
	FROM alpine:latest	
	ENV JAVA_HOME=/jre	
	ENV PATH="${JAVA_HOME}/bin:${PATH}"
		
	# copy JRE from the base image	
	COPY --from=corretto-jdk /customjre $JAVA_HOME
		  
	# Add an extra root CA certificate	
	ADD https://example.com/extra-ca.pem $JAVA_HOME/lib/security/extra-ca.pem	
	RUN echo "<sha256 sum of the certificate>  $JAVA_HOME/lib/security/wolt-ca.pem" | sha256sum -c - && \	
	    cd $JAVA_HOME/lib/security && \	
	    keytool -cacerts -storepass changeit -noprompt -trustcacerts -importcert -alias extra-ca -file extra-ca.pem		
	
	# Add app user	
	ARG APPLICATION_USER=appuser	
	RUN adduser --no-create-home -u 1000 -D $APPLICATION_USER
		  	
	# Configure working directory	
	RUN mkdir /app && \	
	    chown -R $APPLICATION_USER /app			
	USER 1000		  	
	COPY --chown=1000:1000 ./app.jar /app/app.jar	
	WORKDIR /app		  	
	EXPOSE 8080	
	ENTRYPOINT [ "/jre/bin/java", "-jar", "/app/app.jar" ]


You can now use the host network stack (e.g., docker run --net=host) when launching a Docker container, which will perform identically to the Native column
>docker run --net=host