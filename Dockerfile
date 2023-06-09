FROM python:3.9-slim as build

ENV APP_HOME /app
WORKDIR $APP_HOME

COPY ./  /app/
RUN pip install build install
RUN python -m build

FROM python:3.9-slim
ENV APP_HOME /app
WORKDIR $APP_HOME

COPY --from=build /app/dist/ /tmp/
RUN pip install /tmp/*.whl

EXPOSE 8080
ENV PORT 8080
ENTRYPOINT [ "/usr/local/bin/python3", "-m", "dali_poo"]
