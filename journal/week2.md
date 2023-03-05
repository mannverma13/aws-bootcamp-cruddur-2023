# Week 2 — Distributed Tracing

This week we learnt about distributed tracing. How can we logs different services of our app.
Distributed tracing is a method of tracking application requests as they flow from frontend devices to backend services and databases. Developers can use distributed tracing to troubleshoot requests that exhibit high latency or errors.It helps to visulize errors using graphs, trace id etc.
It logs information for a transaction as it flows through differnet services, conatiners, infrstructure.

This week we use three different services to perfrom distibuted tracing.

##  1. Honeycomb.io
Honeycomb provides tracing and logging functions. t provides herrarical tracing bu creating unique parent id and child id. It provides event based tracing with each event known as spans.
Honeycomb prvides differnet methods to analyse data using queries, graphical structurem, or by diagram flow.

A span includes below key paramenters which help to analyse data.
 
A serviceName identifying the service the span is from
A name identifying the role of the span (like function or method name)
A timestamp that corresponds to the start of the span
A duration that describes how long that unit of work took to complete
An ID that uniquely identifies the span
A traceID identifying which trace the span belongs to
A parentID representing the parent span that called this span
Any additional metadata that might be helpful.

# add to app.py

```python
# HoneyComb ------
from opentelemetry import trace
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
```

```python
# Initialize tracing and an exporter that can send data to Honeycomb
provider = TracerProvider()
processor = BatchSpanProcessor(OTLPSpanExporter())
provider.add_span_processor(processor)
trace.set_tracer_provider(provider)
tracer = trace.get_tracer(__name__)
```

```python
# Honeycmb---
# Initialize automatic instrumentation with Flask
FlaskInstrumentor().instrument_app(app)
RequestsInstrumentor().instrument()
```

##  2. AWS X-Ray

