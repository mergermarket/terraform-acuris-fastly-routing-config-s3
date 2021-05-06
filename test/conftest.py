"Shared fixtures"

import os
import pytest
import tftest


BASEDIR = os.path.dirname(os.path.dirname(__file__))


@pytest.fixture(scope='session')
def _plan_runner():
  "Returns a function to run Terraform plan on a fixture."

  def run_plan(fixture_path, targets=None, refresh=True, tf_var_file=None, **tf_vars):
    "Runs Terraform plan and returns parsed output."
    tf = tftest.TerraformTest(fixture_path, BASEDIR,
                              os.environ.get('TERRAFORM', 'terraform'))
    tf.setup(cleanup_on_exit=False)
    return tf.plan(output=True, refresh=refresh, tf_vars=tf_vars, targets=targets, tf_var_file=tf_var_file)
  return run_plan


@pytest.fixture(scope='session')
def plan_runner(_plan_runner):
  "Returns a function to run Terraform plan on a module fixture."

  def run_plan(fixture_path, targets=None, tf_var_file=None, **tf_vars):
    "Runs Terraform plan and returns plan and module resources."
    plan = _plan_runner(fixture_path, targets=targets, tf_var_file=tf_var_file, **tf_vars)
    # skip the fixture
    return plan

  return run_plan


@pytest.fixture(scope='session')
def e2e_plan_runner(_plan_runner):
  "Returns a function to run Terraform plan on an end-to-end fixture."

  def run_plan(fixture_path, targets=None, refresh=True, tf_var_file=None, **tf_vars):
    "Runs Terraform plan on an end-to-end module using defaults, returns data."
    plan = _plan_runner(fixture_path, targets=targets, refresh=refresh, tf_var_file=tf_var_file, **tf_vars)
    # skip the fixture
    root_module = plan.root_module['child_modules'][0]
    modules = dict((mod['address'], mod['resources'])
                   for mod in root_module['child_modules'])
    resources = [r for m in modules.values() for r in m]
    return plan, modules, resources

  return run_plan


@pytest.fixture(scope='session')
def example_plan_runner(_plan_runner):
  "Returns a function to run Terraform plan on documentation examples."

  def run_plan(fixture_path):
    "Runs Terraform plan and returns count of modules and resources."
    plan = _plan_runner(fixture_path)
    # the fixture is the example we are testing
    return (
        len(plan.modules),
        sum(len(m.resources) for m in plan.modules.values()))

  return run_plan


@pytest.fixture(scope='session')
def apply_runner():
  "Returns a function to run Terraform apply on a fixture."

  def run_apply(fixture_path,tf_var_file=None, **tf_vars):
    "Runs Terraform apply and returns parsed output"
    tf = tftest.TerraformTest(fixture_path, BASEDIR,
                              os.environ.get('TERRAFORM', 'terraform'))
    tf.setup(cleanup_on_exit=False)
    apply = tf.apply(tf_vars=tf_vars, tf_var_file=tf_var_file)
    output = tf.output(json_format=True)
    return apply, output

  return run_apply