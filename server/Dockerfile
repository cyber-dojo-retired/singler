FROM  cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

# - - - - - - - - - - - - - - - - - -
# copy source & set ownership
# - - - - - - - - - - - - - - - - - -

RUN adduser \
  -D       `# no password` \
  -H       `# no home dir` \
  -u 19662 `# user-id`     \
  singler  `# user-name`

ARG                   SINGLER_HOME=/app
COPY .                ${SINGLER_HOME}
RUN  chown -R singler ${SINGLER_HOME}

# - - - - - - - - - - - - - - - - -
# git commit sha image is built from
# - - - - - - - - - - - - - - - - -

ARG SHA
RUN echo ${SHA} > ${SINGLER_HOME}/sha.txt

# - - - - - - - - - - - - - - - - - -
# bring it up
# - - - - - - - - - - - - - - - - - -

USER singler
EXPOSE 4517
CMD [ "./up.sh" ]

