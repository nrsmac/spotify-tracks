include .env

.PHONY: download extract upload pipeline

## Run full pipeline: download, extract, upload
pipeline: download extract upload

## Download dataset from Kaggle
download:
	mkdir -p $(DATA_DIR)
	curl -L -C - -o $(DATA_DIR)/$(DATASET_ZIP) $(DATASET_URL)

## Extract dataset
extract:
	unzip -o $(DATA_DIR)/$(DATASET_ZIP) -d $(DATA_DIR)/extracted

## Upload extracted data to S3
upload:
	aws s3 sync $(DATA_DIR)/extracted/ s3://$(S3_BUCKET)/raw



