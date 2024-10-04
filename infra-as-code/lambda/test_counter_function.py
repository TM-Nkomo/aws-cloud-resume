import unittest
import boto3
from .counter_function import lambda_handler

class TestLambdaFunction(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
        cls.table = cls.dynamodb.Table('cloud-resume-test')

    def setUp(self):
        response = self.table.get_item(Key={'id': '1'})
        self.original_views = response['Item']['views']

    def tearDown(self):
        self.table.put_item(Item={'id': '1', 'views': self.original_views})

    # Test for accurate increments
    def test_lambda_handler(self):
        event = {}
        context = None

        new_views = lambda_handler(event, context)

        self.assertEqual(new_views, self.original_views + 1)

        response = self.table.get_item(Key={'id': '1'})
        self.assertEqual(response['Item']['views'], self.original_views + 1)

if __name__ == '__main__':
    unittest.main()
