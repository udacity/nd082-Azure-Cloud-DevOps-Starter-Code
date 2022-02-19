az policy assignment create --name 'tagging-policy-assignment' \
                            --display-name 'resource tagging assignment' \
                            --scope /subscriptions/'0bf66a04-23c0-4307-90cd-dae3b7ec4c35' \
                            --policy /subscriptions/0bf66a04-23c0-4307-90cd-dae3b7ec4c35/providers/Microsoft.Authorization/policyDefinitions/tagging-policy
