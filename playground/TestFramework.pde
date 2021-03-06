import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

boolean verbose = false;

void runTests(Class cls) {

  int failures = 0;
  int runs = 0;
  int testCount = 0;
  try {
    Method[] methods = cls.getMethods();
    Constructor ctor = cls.getDeclaredConstructor(playground.class);
    TestCase instance = (TestCase)ctor.newInstance(this);

    for (Method method : methods) {
      if (method.getName().startsWith("test")) {
        testCount++;
      }
    }
    int i = 1;

    for (Method method : methods) {
      if (method.getName().startsWith("test")) {
        instance.setUp();
        String prefix = i + "/" + testCount + "] " + cls.getName() + "." + method.getName() + " ";
        try {
          runs++;
          if (verbose) {
            print(prefix + "RUNNING\n");
          }
          method.invoke(instance);
          print (prefix + "PASSED\n");
        } 
        catch (Exception e) {
          Throwable realError = e.getCause();
          failures++;
          print(prefix + "FAILED");
          realError.printStackTrace(System.out);
          print ("\n");
        } 
        finally {
          instance.tearDown();
          i++;
        }
      }
    }
  } 
  catch (Exception e) {
    print(e);
    e.printStackTrace(System.out);
  } 
  finally {
    print(failures + " of " + testCount + " tests failed\n");
    if (runs != testCount) {
      print("Only " + runs + " of " + testCount + " tests ran\n");
    }
  }
}

public class TestCase {

  void setUp() {
  }

  void tearDown() {
  }

  void fail(String message) {
    throw new AssertionError(message);
  }

  void assertEqual(Object a, Object b) {
    assertEqual(a, b, a + " != " + b);
  }

  void assertEqual(Object a, Object b, String message) {
    if (a == null) {
      assertNull(b, message);
    } else {
      assertTrue(a.equals(b), message);
    }
  }
  
  void assertNotEqual(Object a, Object b) {
    assertNotEqual(a, b, a + " == " + b);
  }
  
  void assertNotEqual(Object a, Object b, String message) {
    if (a == null) {
      assertNotNull(b, message); 
    } else {
      assertFalse(a.equals(b), message); 
    }
  }

  void assertTrue(boolean value) {
    assertTrue(value, "Expecting true; got false");
  }

  void assertTrue(boolean value, String message) {
    if (!value) fail(message);
  }

  void assertFalse(boolean value) {
    assertFalse(value, "Expecting false; got true");
  }

  void assertFalse(boolean value, String message) {
    if (value) fail(message);
  }

  void assertNull(Object value) {
    assertNull(value, "Expecting null, got " + value);
  }
  
  void assertNull(Object value, String message) {
    assertTrue(value == null, message); 
  }

  void assertNotNull(Object value) {
    assertNotNull(value, "Expecting not null, got null");
  }
  
  void assertNotNull(Object value, String message) {
    assertFalse(value == null, message); 
  }
}
