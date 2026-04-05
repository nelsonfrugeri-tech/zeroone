# Validation Protocol

## N-Source Rule
- Minimum 3 independent sources for any technical claim
- "Independent" = different authors/organizations
- Vendor blogs count as ONE source (biased)

## Date Check
| Domain | Max age |
|--------|---------|
| AI/ML models | 3 months |
| Frameworks/libs | 6 months |
| Architecture patterns | 2 years |
| CS fundamentals | Timeless |

## Bias Detection
| Source type | Bias risk | How to compensate |
|-------------|-----------|-------------------|
| Vendor blog | High (selling product) | Cross-check with independent benchmarks |
| Conference talk | Medium (promoting approach) | Check if approach has independent adopters |
| GitHub README | Medium (selling project) | Check issues, real-world usage |
| Academic paper | Low-medium (may overfit benchmarks) | Check reproducibility, code availability |
| Independent benchmark | Low | Verify methodology is sound |

## Validation Checklist
- [ ] Claim backed by ≥3 sources
- [ ] Sources are recent enough for the domain
- [ ] At least 1 source is independent (non-vendor)
- [ ] Methodology of benchmarks is disclosed
- [ ] Counter-arguments considered
