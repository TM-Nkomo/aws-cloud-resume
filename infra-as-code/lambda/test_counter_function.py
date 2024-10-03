import unittest
import boto3
from .counter_function import lambda_handler

class TestLambdaFunction(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        # Connect to the actual AWS DynamoDB
        cls.dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
        cls.table = cls.dynamodb.Table('cloud-resume-test')

    def setUp(self):
        # Fetch the current view count from the actual table
        response = self.table.get_item(Key={'id': '1'})
        self.original_views = response['Item']['views']

    def tearDown(self):
        # Restore the original view count to avoid affecting the real data
        self.table.put_item(Item={'id': '1', 'views': self.original_views})

    def test_lambda_handler(self):
        # Prepare the event and context
        event = {}
        context = None

        # Call lambda_handler and fetch the new view count
        new_views = lambda_handler(event, context)

        # Assert that the views were incremented by 1
        self.assertEqual(new_views, self.original_views + 1)

        # Verify the table has been updated with the incremented view count
        response = self.table.get_item(Key={'id': '1'})
        self.assertEqual(response['Item']['views'], self.original_views + 1)

if __name__ == '__main__':
    unittest.main()
