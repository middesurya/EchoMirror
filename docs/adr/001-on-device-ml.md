# ADR 001: On-Device ML for Privacy-First Analysis

## Status
**Accepted** — January 2026

## Context

EchoMirror requires analysis of user reflections to detect sentiment, emotions, and themes. Users share deeply personal thoughts, making privacy a critical concern. We needed to decide between:

1. **Cloud-based ML APIs** (OpenAI, Google Cloud, AWS) — More accurate, but data leaves device
2. **On-device ML** (ML Kit, TFLite) — Less accurate, but complete privacy
3. **Hybrid approach** — Critical analysis on-device, optional cloud features

## Decision

**We chose on-device ML as the default for all core analysis features.**

Specifically:
- **Face detection & emotion**: Google ML Kit (on-device)
- **Sentiment analysis**: Rule-based with optional TFLite model
- **Story generation**: Template-based on-device
- **Image generation**: Replicate API (opt-in, cloud-based)

## Rationale

### Privacy as a Core Value
- Users share vulnerable, personal reflections
- Mental health adjacent apps have higher privacy stakes
- GDPR compliance is simpler without cloud data processing
- User trust is the foundation of engagement

### Technical Benefits
- **Offline functionality**: Works without internet
- **Low latency**: No network round-trip
- **Cost**: No per-request API charges
- **Simplicity**: No backend infrastructure to maintain

### Trade-offs Accepted
- Sentiment analysis is less nuanced than GPT-4
- No continuous model improvements
- Larger app bundle size (~15MB for models)
- Limited to pre-trained model capabilities

## Consequences

### Positive
- ✅ Zero personal data transmitted to external servers
- ✅ GDPR compliant by design (no data processor agreements needed)
- ✅ Works in airplane mode
- ✅ No API costs for core features
- ✅ Strong differentiator vs competitors

### Negative
- ⚠️ Sentiment accuracy ~85% vs ~95% for cloud models
- ⚠️ App bundle larger than cloud-dependent alternatives
- ⚠️ Cannot easily A/B test model improvements
- ⚠️ Emotion detection limited to basic categories

### Mitigations
- Clear user expectations about analysis limitations
- Fallback to rule-based analysis if TFLite fails
- Optional Replicate API for users who want AI artwork
- Model updates via app store releases

## Alternatives Considered

### 1. OpenAI API for All Analysis
**Rejected**: Privacy concerns outweigh accuracy benefits. Users sharing personal reflections shouldn't have data sent to third parties by default.

### 2. Self-Hosted ML Backend
**Rejected**: Adds operational complexity, hosting costs, and still involves data transmission. Doesn't solve the core privacy concern.

### 3. Federated Learning
**Considered for Future**: Could improve models without centralizing data. Too complex for MVP, may revisit post-launch.

## References

- [Google ML Kit Documentation](https://developers.google.com/ml-kit)
- [TensorFlow Lite Guide](https://www.tensorflow.org/lite)
- [GDPR Data Processing Requirements](https://gdpr.eu/data-processing-agreement/)

---

*This ADR documents a key architectural decision. Updates require team discussion.*
