FROM python:3.11-slim AS builder

WORKDIR /build

COPY src/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt --target=/build/packages

FROM python:3.11-slim AS final

RUN groupadd --gid 1001 appgroup \
    && useradd --uid 1001 --gid appgroup --no-create-home appuser

WORKDIR /app

COPY --from=builder /build/packages /usr/local/lib/python3.11/site-packages/

COPY src/app.py .

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')"

CMD ["python", "-m", "gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]