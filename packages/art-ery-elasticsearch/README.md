# Art-Ery Elasticsearch

ArtEry Pipeline for Elasticsearch

# Development Server

##### Get

* [download elastic search](https://www.elastic.co/downloads/elasticsearch)
* [official installation doc](https://www.elastic.co/guide/en/elasticsearch/guide/current/running-elasticsearch.html)

### Local Testing

Download the latest:

* https://www.elastic.co/downloads/elasticsearch

```bash
> ./elasticsearch-5.3.1/bin/elasticsearch
```

##### Handy

* [list all indicies](http://localhost:9200/*?pretty): `&ArtRestClient.getJson "http://localhost:9200/*"`
* [list all records](http://localhost:9200/my_index/_search?pretty): `&ArtRestClient.getJson "http://localhost:9200/my_index/_search"`
* delete index: `&ArtRestClient.delete "http://localhost:9200/my_index"`


##### Verify the Server:

* [click to test](http://localhost:9200/?pretty)

You should see something like this:

```json
{
  "name" : "TD4A4C2",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "3AH3n90VQEiuVbei0jKHJw",
  "version" : {
    "number" : "5.3.0",
    "build_hash" : "3adb13b",
    "build_date" : "2017-03-23T03:31:50.652Z",
    "build_snapshot" : false,
    "lucene_version" : "6.4.1"
  },
  "tagline" : "You Know, for Search"
}
```

##### Run tests

```
npm test
```


### Remote Testing

Setup elasticsearch on AWS. Set up your IAM user. Use the comand below, but replace YOUR_SECRET and YOUR_KEY with your own keys.

```bash
artConfig='{"Art.Ery.Elasticsearch":{"credentials":{"secretAccessKey":"YOUR_SECRET","accessKeyId":"YOUR_KEY"},"endpoint":"https://search-imikimi-zo-ws32l6szgwqfv6hivvp7j5wlsq.us-east-1.es.amazonaws.com"}}' npm test
```

