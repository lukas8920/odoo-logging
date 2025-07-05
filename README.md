# odoo-logging

This project is designed to support logging infrastructure using tools such as Loki and Prometheus. Specifically, this setup is intended for Docker containers within the broader Odoo deployment and for monitoring system metrics.

## Features

- Integrates with Loki for log aggregation.
- Supports Prometheus for metrics collection.
- Provides setup instructions for Linux environments.

## Setup Instructions

1. **Check and Clean Loki Delete Requests**
   - Regularly ensure that `/tmp/loki/delete-requests/` is not accumulating unnecessary delete requests.

2. **Set Up Max Log File Limits**
   - Configure Docker's daemon.json to set log file limits.
   - Restart Docker:
     ```sh
     sudo systemctl restart docker.service
     ```

3. **System Preparation**
   - For Linux system data, ensure import 1860 is in place.

4. **Create Required Folders**
   - Add the following folders to your project root:
     - `loki-data`
     - `prometheus-data`

5. **Set Folder Permissions**
   - Allow access to the Prometheus folder:
     ```sh
     sudo chown -R 65534:65534 ./prometheus-data
     ```
   - Allow access to the Loki folder:
     ```sh
     sudo chown -R 10001:10001 ./loki-data
     ```