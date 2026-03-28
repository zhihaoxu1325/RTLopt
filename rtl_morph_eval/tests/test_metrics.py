from dataset.models import SynthesisMetrics
from analysis.normalization import normalize_metrics


def test_normalize_metrics():
    a = SynthesisMetrics(10, 20, 30, 2, 3)
    b = SynthesisMetrics(5, 10, 15, 1, 1.5)
    r = normalize_metrics(a, b)
    assert r["wires"] == 2
    assert r["cells"] == 2
