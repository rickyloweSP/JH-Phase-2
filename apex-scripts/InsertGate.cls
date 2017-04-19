Gate__c G = new gate__c(name = 'test' + string.valueOf(dateTime.now()), gate_number__c = '1', opportunity__c = '006O0000008kzY6');
insert G;