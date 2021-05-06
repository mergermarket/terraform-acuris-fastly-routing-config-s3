import unittest
import os
import re
import json
from subprocess import check_call, check_output

FIXTURES_DIR = os.path.join(os.path.dirname(__file__), 'infra')


def assert_output(testname, output):
    with open(f'test/files/{testname}.json', 'r') as f:
        data = json.load(f)
    
        assert sorted(data) == sorted(output)


def test_resources(apply_runner):
    _, output = apply_runner(
        FIXTURES_DIR,
        defaults_vcl_recv_condition="test-cond",
        defaults_backend_name="test-backend",
        defaults_s3_bucket_name="test-bucket",
        defaults_aws_access_key_id="JKCAUEFV2ONFFOFMSSLA",
        defaults_aws_secret_access_key="P2WPSu68Bfl89j72vT+bXYZB7SjlOwhT4whqt27")

    assert_output("output",output)