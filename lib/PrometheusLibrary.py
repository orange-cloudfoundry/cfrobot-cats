from prometheus_client.parser import text_string_to_metric_families


class PrometheusLibrary(object):
    def prom_search_metric_by_labels(self, metrics, metric_name, **labels):
        fams = text_string_to_metric_families(metrics)
        final_samples = []
        for family in fams:
            for sample in family.samples:
                if sample.name != metric_name:
                    continue
                to_continue = False
                for key, value in labels.items():
                    if sample.labels[key] != value:
                        to_continue = True
                        break
                if to_continue:
                    continue
                final_samples.append(sample)
        print(len(final_samples))
        if len(final_samples) == 0:
            raise AssertionError("Could not find metrics with this labels")
        return final_samples[0].value
