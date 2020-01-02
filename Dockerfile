# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
FROM maven:3.5-jdk-8-alpine AS build
LABEL Author="jpq <@.com>"
WORKDIR /src
RUN apk add --no-cache git \
    && git clone https://github.com/skywater/dubbo-admin-2.6.0.git \
    && mvn clean package -Dmaven.test.skip=true

# timezone    
RUN apk add -U tzdata \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

FROM tomcat:9-jre8-alpine
# timezone
COPY --from=build /etc/localtime /etc/localtime
WORKDIR /usr/local/tomcat/webapps
ARG version=2.0.0
RUN rm -rf ROOT
COPY --from=build /src/dubbo-admin-2.6.0/target/dubbo-admin-${version}.war .
RUN mv dubbo-admin-${version}.war ROOT.war