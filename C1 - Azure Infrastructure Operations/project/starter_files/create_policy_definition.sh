az policy definition create --name 'tagging-policy' --description 'This policy denies resource deployment without tagging' --rules '{
    "if": {
        "allOf": [{
            "not": {
                "field": "tags",
                "exists": "true"
                }
            },
            {
                "field": "type",
                "equals": "Microsoft.Resources/subscriptions"
            }
        ]
    },
    "then": {
        "effect": "deny"
    }
}'
