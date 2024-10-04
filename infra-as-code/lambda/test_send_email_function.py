import json
import pytest
from unittest.mock import patch, MagicMock
from botocore.exceptions import ClientError
from .send_email_function import lambda_handler

# Sample event for testing
def get_test_event():
    return {
        'body': json.dumps({
            'name': 'John Doe',
            'email': 'johndoe@example.com',
            'message': 'Hello, this is a test message.'
        })
    }

# Test for successful email sending
@patch('boto3.client')
def test_send_email_success(mock_boto_client):
    mock_ses_client = MagicMock()
    mock_boto_client.return_value = mock_ses_client
    mock_ses_client.send_email.return_value = {'MessageId': 'mock_message_id'}

    response = lambda_handler(get_test_event(), None)

    assert response['statusCode'] == 200
    assert json.loads(response['body']) == 'Email sent successfully!'
    mock_ses_client.send_email.assert_called_once()

# Test for failed email sending due to a ClientError
@patch('boto3.client')
def test_send_email_failure(mock_boto_client):
    mock_ses_client = MagicMock()
    mock_boto_client.return_value = mock_ses_client
    mock_ses_client.send_email.side_effect = ClientError(
        {"Error": {"Message": "Mock error message"}}, "SendEmail"
    )

    response = lambda_handler(get_test_event(), None)

    assert response['statusCode'] == 500
    assert json.loads(response['body']) == "Failed to send email: Mock error message"
