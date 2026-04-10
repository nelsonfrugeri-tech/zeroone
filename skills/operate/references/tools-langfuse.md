# Langfuse

## LLM Observability

### What to Trace
- Prompt template + variables
- Model, temperature, max_tokens
- Input/output token counts
- Latency (TTFT, total)
- Cost per request
- User feedback scores

### Integration
```python
from langfuse import Langfuse
langfuse = Langfuse()

trace = langfuse.trace(name="chat", user_id=user_id)
generation = trace.generation(
    name="llm-call",
    model="claude-sonnet-4-6",
    input=messages,
    output=response.content,
    usage={"input": input_tokens, "output": output_tokens}
)
```

### Evaluation
- Model-graded evaluation (LLM-as-judge)
- Human annotation workflows
- A/B testing prompt variants

### Version: Langfuse 3.x (2026 stable, self-hosted or cloud)
