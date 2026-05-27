/**
 * Metric Service (disabled)
 */

class MetricService {
    async sendMetrics() {
        return null;
    }
}

const metricService = new MetricService();
module.exports = metricService;
