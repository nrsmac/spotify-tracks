DATASET_URL := https://www.kaggle.com/api/v1/datasets/download/lordpatil/spotify-metadata-by-annas-archive
DATASET_ZIP := spotify-metadata-by-annas-archive.zip
DATA_DIR := data
S3_BUCKET := noah-annasarchive-spotify-metadata

.PHONY: download extract upload pipeline clean

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
	aws s3 sync $(DATA_DIR)/extracted/ s3://$(S3_BUCKET)/ \
		--no-progress \
		--only-show-errors

## Remove local data files
clean:
	rm -rf $(DATA_DIR)
