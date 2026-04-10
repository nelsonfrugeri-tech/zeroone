---
name: ai-engineer
description: |
  AI/ML engineering knowledge base (2026). Covers LLM integration patterns (Anthropic, OpenAI,
  Bedrock, Gemini), prompt engineering (few-shot, chain-of-thought, structured outputs), RAG
  architecture (naive, advanced, agentic), chunking strategies, embeddings, Qdrant vector database,
  semantic caching (MongoDB, Redis), agent frameworks (LangGraph, custom loops), multi-provider
  fallback strategy, testing AI systems (mocking, golden datasets, LLM-as-judge, ragas evaluation),
  production patterns (cost optimization, reliability, rate limit handling), and security
  (prompt injection prevention, PII handling, content filtering).
  Use when: (1) Building LLM/RAG/agent systems, (2) Integrating multiple LLM providers,
  (3) Implementing semantic caching, (4) Testing or evaluating AI systems, (5) Optimizing AI costs.
  Triggers: /ai-ml, /ai, LLM, RAG, agent, langchain, langgraph, qdrant, anthropic, openai, embeddings.
type: knowledge
---

# AI/ML — Knowledge Base

## Purpose

This skill is the knowledge base for AI/ML engineering in Python (2026).
It covers LLM integration, RAG architecture, agent frameworks, evaluation, and production patterns.

**What this skill contains:**
- LLM integration (Anthropic Claude, OpenAI GPT, AWS Bedrock, Google Gemini)
- Prompt engineering (few-shot, CoT, structured outputs, Pydantic AI)
- RAG architecture (naive, advanced, agentic)
- Chunking strategies and embedding models
- Vector databases (Qdrant)
- Semantic caching (MongoDB, Redis)
- Agent frameworks (LangGraph, custom loops)
- Multi-provider fallback and routing
- Testing AI systems (mocking, golden datasets, ragas, LLM-as-judge)
- Observability (structured logging, Langfuse)
- Security (prompt injection, PII handling)
- Production patterns (cost optimization, reliability)

---

## Fundamental Principles

1. **Determinism where possible** — temperature=0 when reproducibility matters, seed when available
2. **Test AI systems** — mock LLM calls in unit tests, golden datasets for regression, LLM-as-judge for quality
3. **Observe everything** — log prompts + responses (with PII redaction), track tokens and cost
4. **Cache aggressively** — semantic caching for similar queries; LLM tokens are expensive
5. **Multi-provider** — no single provider dependency; fallback strategy is always defined
6. **Safety first** — validate all inputs, filter outputs, rate limit, prevent prompt injection

---

## 1. LLM Integration

### Anthropic Claude SDK

```python
import anthropic
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type

client = anthropic.Anthropic(api_key=settings.anthropic_api_key.get_secret_value())

@retry(
    retry=retry_if_exception_type(anthropic.RateLimitError),
    wait=wait_exponential(multiplier=1, min=4, max=60),
    stop=stop_after_attempt(3),
)
async def generate(
    prompt: str,
    system: str | None = None,
    model: str = "claude-sonnet-4-5",
    max_tokens: int = 1024,
    temperature: float = 0.0,
) -> str:
    message = await client.messages.create(
        model=model,
        max_tokens=max_tokens,
        temperature=temperature,
        system=system or "You are a helpful assistant.",
        messages=[{"role": "user", "content": prompt}],
    )
    return message.content[0].text

# Streaming
async def stream_generate(prompt: str) -> AsyncIterator[str]:
    async with client.messages.stream(
        model="claude-sonnet-4-5",
        max_tokens=1024,
        messages=[{"role": "user", "content": prompt}],
    ) as stream:
        async for text in stream.text_stream:
            yield text
```

### Structured Outputs with Pydantic AI

```python
from pydantic import BaseModel
from pydantic_ai import Agent

class AnalysisResult(BaseModel):
    sentiment: str  # positive | negative | neutral
    confidence: float  # 0-1
    key_points: list[str]
    summary: str

agent = Agent(
    "claude-sonnet-4-5",
    result_type=AnalysisResult,
    system_prompt="Analyze the text and return structured JSON.",
)

async def analyze_text(text: str) -> AnalysisResult:
    result = await agent.run(text)
    return result.data  # fully typed AnalysisResult
```

### OpenAI SDK

```python
from openai import AsyncOpenAI

openai_client = AsyncOpenAI(api_key=settings.openai_api_key.get_secret_value())

async def openai_generate(prompt: str, model: str = "gpt-4o-mini") -> str:
    response = await openai_client.chat.completions.create(
        model=model,
        messages=[{"role": "user", "content": prompt}],
        temperature=0,
        max_tokens=1024,
    )
    return response.choices[0].message.content or ""
```

**Reference:** [references/llm-providers.md](references/llm-providers.md)

---

## 2. Prompt Engineering

### Prompt Templates

```python
from string import Template

SYSTEM_PROMPT = """You are a helpful assistant specializing in {domain}.
Rules:
- Answer only based on the provided context
- If unsure, say "I don't have enough information"
- Format responses in {format}"""

def build_rag_prompt(question: str, context: str) -> str:
    return f"""Context:
{context}

Question: {question}

Answer based only on the context above. If the context doesn't contain the answer, say so."""
```

### Few-Shot Examples

```python
FEW_SHOT_EXAMPLES = [
    {
        "input": "What is the capital of France?",
        "output": '{"answer": "Paris", "confidence": 0.99, "source": "general knowledge"}',
    },
    {
        "input": "What is 2+2?",
        "output": '{"answer": "4", "confidence": 1.0, "source": "arithmetic"}',
    },
]

def build_few_shot_prompt(question: str, examples: list[dict]) -> str:
    example_text = "\n\n".join(
        f"Input: {ex['input']}\nOutput: {ex['output']}" for ex in examples
    )
    return f"""Examples:
{example_text}

Input: {question}
Output:"""
```

### Chain of Thought

```python
COT_SYSTEM = """Think step by step before answering.
Format:
<thinking>your reasoning here</thinking>
<answer>final answer here</answer>"""

def extract_answer_from_cot(response: str) -> str:
    """Extract the final answer from a CoT response."""
    import re
    match = re.search(r"<answer>(.*?)</answer>", response, re.DOTALL)
    return match.group(1).strip() if match else response
```

**Reference:** [references/prompt-engineering.md](references/prompt-engineering.md)

---

## 3. RAG Architecture

### Pattern Selection

| Pattern | When to Use | Complexity |
|---------|------------|-----------|
| **Naive RAG** | MVP, < 10K documents, no quality requirements | Low |
| **Advanced RAG** | Production, quality matters, large corpus | Medium |
| **Agentic RAG** | Complex multi-step questions, tool use needed | High |

### Naive RAG Implementation

```python
from qdrant_client import QdrantClient
from qdrant_client.models import VectorParams, Distance, PointStruct
import asyncio

class SimpleRAG:
    def __init__(
        self,
        qdrant_url: str,
        collection_name: str,
        embedding_model: str = "text-embedding-3-small",
    ) -> None:
        self.qdrant = QdrantClient(url=qdrant_url)
        self.collection = collection_name
        self.openai = AsyncOpenAI()
        self.embedding_model = embedding_model

    async def embed(self, text: str) -> list[float]:
        response = await self.openai.embeddings.create(
            model=self.embedding_model,
            input=text,
        )
        return response.data[0].embedding

    async def retrieve(self, query: str, top_k: int = 5) -> list[str]:
        query_vector = await self.embed(query)
        results = self.qdrant.search(
            collection_name=self.collection,
            query_vector=query_vector,
            limit=top_k,
            with_payload=True,
        )
        return [hit.payload["text"] for hit in results]

    async def generate(self, question: str, context: list[str]) -> str:
        context_str = "\n\n".join(context)
        prompt = build_rag_prompt(question, context_str)
        return await generate(prompt)

    async def query(self, question: str) -> str:
        context = await self.retrieve(question)
        return await self.generate(question, context)
```

### Chunking Strategies

| Strategy | Use Case | Chunk Size |
|----------|---------|-----------|
| Fixed-size | Generic text, no structure | 512-1024 tokens |
| Sentence | Narrative content | 1-3 sentences |
| Recursive | Code, mixed content | Variable |
| Semantic | High-quality retrieval | Variable |
| Document-aware | PDFs, structured docs | Section-based |

```python
from langchain.text_splitter import RecursiveCharacterTextSplitter

splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200,
    separators=["\n\n", "\n", ". ", " ", ""],
)

chunks = splitter.split_text(document_text)
```

**Reference:** [references/rag-architecture.md](references/rag-architecture.md)

---

## 4. Qdrant Vector Database

### Collection Setup

```python
from qdrant_client import QdrantClient
from qdrant_client.models import (
    VectorParams, Distance, PointStruct,
    HnswConfigDiff, OptimizersConfigDiff,
)

client = QdrantClient(url=settings.qdrant_url)

def create_collection(
    name: str,
    vector_size: int = 1536,  # OpenAI text-embedding-3-small
) -> None:
    client.create_collection(
        collection_name=name,
        vectors_config=VectorParams(
            size=vector_size,
            distance=Distance.COSINE,
        ),
        hnsw_config=HnswConfigDiff(
            m=16,         # connections per layer (higher = better recall, more memory)
            ef_construct=100,  # build quality
        ),
        optimizers_config=OptimizersConfigDiff(
            indexing_threshold=20_000,  # start indexing after N vectors
        ),
    )

# Batch upsert
def upsert_chunks(collection: str, chunks: list[dict]) -> None:
    """chunks: [{id, vector, text, metadata}]"""
    points = [
        PointStruct(
            id=chunk["id"],
            vector=chunk["vector"],
            payload={"text": chunk["text"], **chunk["metadata"]},
        )
        for chunk in chunks
    ]
    client.upsert(collection_name=collection, points=points, wait=True)

# Search with filters
def search(
    collection: str,
    query_vector: list[float],
    filter_conditions: dict | None = None,
    top_k: int = 5,
    score_threshold: float = 0.7,
) -> list[dict]:
    from qdrant_client.models import Filter, FieldCondition, MatchValue

    filter_ = None
    if filter_conditions:
        filter_ = Filter(
            must=[
                FieldCondition(key=k, match=MatchValue(value=v))
                for k, v in filter_conditions.items()
            ]
        )

    results = client.search(
        collection_name=collection,
        query_vector=query_vector,
        query_filter=filter_,
        limit=top_k,
        score_threshold=score_threshold,
        with_payload=True,
    )
    return [
        {"text": hit.payload["text"], "score": hit.score, "metadata": hit.payload}
        for hit in results
    ]
```

**Reference:** [references/qdrant.md](references/qdrant.md)

---

## 5. Semantic Caching

### Redis Semantic Cache

```python
import hashlib
import json
import numpy as np
from redis import Redis

class SemanticCache:
    def __init__(
        self,
        redis_client: Redis,
        embedding_fn: Callable[[str], list[float]],
        similarity_threshold: float = 0.95,
        ttl_seconds: int = 3600,
    ) -> None:
        self.redis = redis_client
        self.embed = embedding_fn
        self.threshold = similarity_threshold
        self.ttl = ttl_seconds

    def _cosine_similarity(self, a: list[float], b: list[float]) -> float:
        a_arr = np.array(a)
        b_arr = np.array(b)
        return float(np.dot(a_arr, b_arr) / (np.linalg.norm(a_arr) * np.linalg.norm(b_arr)))

    async def get(self, query: str) -> str | None:
        query_vector = await self.embed(query)
        # Check all cached queries for semantic similarity
        for key in self.redis.scan_iter("cache:*"):
            cached = json.loads(self.redis.get(key))
            similarity = self._cosine_similarity(query_vector, cached["vector"])
            if similarity >= self.threshold:
                return cached["response"]
        return None

    async def set(self, query: str, response: str) -> None:
        query_vector = await self.embed(query)
        cache_key = f"cache:{hashlib.sha256(query.encode()).hexdigest()}"
        self.redis.setex(
            cache_key,
            self.ttl,
            json.dumps({"query": query, "vector": query_vector, "response": response}),
        )

# Usage
async def cached_generate(query: str) -> str:
    if cached := await cache.get(query):
        return cached
    response = await generate(query)
    await cache.set(query, response)
    return response
```

**Reference:** [references/semantic-caching.md](references/semantic-caching.md)

---

## 6. Agent Frameworks

### LangGraph State Machine

```python
from langgraph.graph import StateGraph, END
from typing import TypedDict, Annotated
import operator

class AgentState(TypedDict):
    messages: Annotated[list[dict], operator.add]
    context: str
    answer: str | None
    attempts: int

def retrieve_node(state: AgentState) -> AgentState:
    """Retrieve relevant context."""
    query = state["messages"][-1]["content"]
    context = rag.retrieve(query)
    return {"context": "\n".join(context), "attempts": state["attempts"] + 1}

def generate_node(state: AgentState) -> AgentState:
    """Generate answer using context."""
    question = state["messages"][-1]["content"]
    answer = asyncio.run(generate(question, state["context"]))
    return {"answer": answer}

def should_retry(state: AgentState) -> str:
    """Route: retry retrieval or finish."""
    if state["answer"] and "I don't know" not in state["answer"]:
        return "finish"
    if state["attempts"] >= 3:
        return "finish"
    return "retrieve"

# Build graph
graph = StateGraph(AgentState)
graph.add_node("retrieve", retrieve_node)
graph.add_node("generate", generate_node)
graph.set_entry_point("retrieve")
graph.add_edge("retrieve", "generate")
graph.add_conditional_edges("generate", should_retry, {"retrieve": "retrieve", "finish": END})

agent = graph.compile()
```

**Reference:** [references/agent-frameworks.md](references/agent-frameworks.md)

---

## 7. Multi-Provider Strategy

```python
from enum import Enum

class LLMProvider(str, Enum):
    ANTHROPIC = "anthropic"
    OPENAI = "openai"
    BEDROCK = "bedrock"

class MultiProviderClient:
    def __init__(self) -> None:
        self.primary = LLMProvider.ANTHROPIC
        self.fallback_order = [LLMProvider.OPENAI, LLMProvider.BEDROCK]
        self.circuit_breakers: dict[LLMProvider, int] = {}  # failure counts

    async def generate(self, prompt: str, **kwargs: Any) -> str:
        providers = [self.primary] + self.fallback_order
        last_error: Exception | None = None

        for provider in providers:
            if self.circuit_breakers.get(provider, 0) >= 5:
                continue  # circuit open — skip this provider

            try:
                result = await self._call_provider(provider, prompt, **kwargs)
                self.circuit_breakers[provider] = 0  # reset on success
                return result
            except (RateLimitError, ServiceUnavailableError) as exc:
                self.circuit_breakers[provider] = (
                    self.circuit_breakers.get(provider, 0) + 1
                )
                last_error = exc
                logger.warning("provider_failed", provider=provider.value, error=str(exc))
                continue

        raise ExternalServiceError("all LLM providers failed") from last_error
```

---

## 8. Testing AI Systems

### Mock LLM Calls

```python
import pytest
from unittest.mock import AsyncMock, patch

@pytest.fixture
def mock_anthropic_client():
    with patch("anthropic.AsyncAnthropic") as mock_cls:
        client = AsyncMock()
        mock_cls.return_value = client

        # Configure a default response
        client.messages.create.return_value = MagicMock(
            content=[MagicMock(text="Mocked response")],
            usage=MagicMock(input_tokens=10, output_tokens=5),
        )
        yield client

@pytest.mark.asyncio
async def test_rag_query(mock_anthropic_client: AsyncMock) -> None:
    mock_anthropic_client.messages.create.return_value.content[0].text = (
        "Paris is the capital of France."
    )

    result = await rag.query("What is the capital of France?")

    assert "Paris" in result
    mock_anthropic_client.messages.create.assert_called_once()
```

### Golden Dataset for Regression

```python
import json
from pathlib import Path

GOLDEN_DATASET = Path("tests/fixtures/golden_dataset.json")

@pytest.mark.parametrize("case", json.loads(GOLDEN_DATASET.read_text()))
@pytest.mark.asyncio
async def test_rag_golden_dataset(case: dict, mock_anthropic_client: AsyncMock) -> None:
    """Regression test: ensure answers don't degrade."""
    mock_anthropic_client.messages.create.return_value.content[0].text = case["expected_answer"]

    result = await rag.query(case["question"])

    # Exact match or semantic similarity check
    assert case["expected_answer"] in result or _semantic_match(result, case["expected_answer"])
```

### Ragas Evaluation

```python
from ragas import evaluate
from ragas.metrics import faithfulness, answer_relevancy, context_recall
from datasets import Dataset

def evaluate_rag_pipeline(test_cases: list[dict]) -> dict[str, float]:
    """Evaluate RAG quality with ragas metrics."""
    dataset = Dataset.from_list([
        {
            "question": case["question"],
            "answer": case["generated_answer"],
            "contexts": case["retrieved_contexts"],
            "ground_truth": case["expected_answer"],
        }
        for case in test_cases
    ])

    result = evaluate(
        dataset,
        metrics=[faithfulness, answer_relevancy, context_recall],
    )

    return {
        "faithfulness": result["faithfulness"],      # is answer grounded in context?
        "answer_relevancy": result["answer_relevancy"],  # is answer relevant to question?
        "context_recall": result["context_recall"],  # did retrieval find the right chunks?
    }
```

**Reference:** [references/testing-ai.md](references/testing-ai.md)

---

## 9. Security for AI Systems

### Prompt Injection Prevention

```python
import re

INJECTION_PATTERNS = [
    r"ignore previous instructions",
    r"disregard all prior",
    r"forget everything",
    r"system prompt",
    r"you are now",
    r"act as",
]

def validate_user_input(user_input: str) -> str:
    """Detect and block obvious prompt injection attempts."""
    lower = user_input.lower()
    for pattern in INJECTION_PATTERNS:
        if re.search(pattern, lower):
            raise ValidationError("Input contains potentially harmful content")

    # Limit input length
    if len(user_input) > 4000:
        raise ValidationError("Input exceeds maximum length")

    return user_input

def build_safe_prompt(user_input: str, context: str) -> str:
    """Wrap user input to prevent injection."""
    validated = validate_user_input(user_input)
    return f"""Context information:
<context>
{context}
</context>

User question (answer based on context only):
<question>
{validated}
</question>"""
```

### PII Handling

```python
import re

PII_PATTERNS = {
    "email": r"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b",
    "phone": r"\b\d{3}[-.]?\d{3}[-.]?\d{4}\b",
    "ssn": r"\b\d{3}-\d{2}-\d{4}\b",
    "credit_card": r"\b\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}\b",
}

def redact_pii(text: str) -> str:
    """Replace PII with placeholders before sending to LLM or logging."""
    for pii_type, pattern in PII_PATTERNS.items():
        text = re.sub(pattern, f"[{pii_type.upper()}_REDACTED]", text, flags=re.IGNORECASE)
    return text
```

**Reference:** [references/ai-security.md](references/ai-security.md)

---

## 10. Production Cost Optimization

### Model Selection by Task

| Task | Recommended Model | Why |
|------|------------------|-----|
| Simple Q&A, classification | claude-haiku-4-5, gpt-4o-mini | Fast, cheap, sufficient |
| RAG with long context | claude-sonnet-4-5 | Good reasoning, long context |
| Complex analysis, coding | claude-opus-4-5, gpt-4o | Highest quality |
| Embedding | text-embedding-3-small | Fast, cheap, 99% as good |
| High-volume pipeline | Use caching first | Cache hits cost $0 |

### Cost Tracking

```python
COST_PER_MILLION_TOKENS = {
    "claude-haiku-4-5": {"input": 0.80, "output": 4.00},
    "claude-sonnet-4-5": {"input": 3.00, "output": 15.00},
    "claude-opus-4-5": {"input": 15.00, "output": 75.00},
    "gpt-4o-mini": {"input": 0.15, "output": 0.60},
    "gpt-4o": {"input": 2.50, "output": 10.00},
}

def calculate_cost(model: str, input_tokens: int, output_tokens: int) -> float:
    rates = COST_PER_MILLION_TOKENS.get(model)
    if not rates:
        return 0.0
    return (
        input_tokens / 1_000_000 * rates["input"]
        + output_tokens / 1_000_000 * rates["output"]
    )

# Log cost on every LLM call
logger.info(
    "llm_call_completed",
    model=model,
    input_tokens=usage.input_tokens,
    output_tokens=usage.output_tokens,
    cost_usd=calculate_cost(model, usage.input_tokens, usage.output_tokens),
)
```

---

## Reference Files

- [references/llm-providers.md](references/llm-providers.md) — Anthropic, OpenAI, Bedrock, Gemini SDKs
- [references/prompt-engineering.md](references/prompt-engineering.md) — Templates, few-shot, CoT, structured outputs
- [references/rag-architecture.md](references/rag-architecture.md) — RAG patterns, chunking, retrieval
- [references/qdrant.md](references/qdrant.md) — Qdrant setup, indexing, search, filters
- [references/semantic-caching.md](references/semantic-caching.md) — Redis/MongoDB semantic cache
- [references/agent-frameworks.md](references/agent-frameworks.md) — LangGraph, custom agents, tool calling
- [references/testing-ai.md](references/testing-ai.md) — Mocking, golden datasets, ragas evaluation
- [references/ai-security.md](references/ai-security.md) — Prompt injection, PII, content filtering
- [references/cost-optimization.md](references/cost-optimization.md) — Model selection, cost tracking, caching ROI
