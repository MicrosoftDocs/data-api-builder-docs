## Example configuration

```json
{
  "runtime": {
    "pagination": {
      "default-page-size": 100,
      "max-page-size": 100000
    }
  },
  "entities": {
    "Book": {
      "source": {
        "type": "table",
        "object": "dbo.books"
      },
      "mappings": {
        "sku_title": "title",
        "sku_price": "price"
      },
      "relationships": {
        "book_category": {
          "cardinality": "one",
          "target.entity": "Category",
          "source.fields": [ "category_id" ],
          "target.fields": [ "id" ]
        }
      }
    },
    "Category": {
      "source": {
        "type": "table",
        "object": "dbo.categories"
      },
      "relationships": {
        "category_books": {
          "cardinality": "many",
          "target.entity": "Book",
          "source.fields": [ "id" ],
          "target.fields": [ "category_id" ]
        }
      }
    }
  }
}
```