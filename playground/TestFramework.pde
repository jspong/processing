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
          } catch (Exception e) {
            Throwable realError = e.getCause();
            failures++;
            print(prefix + "FAILED");
            realError.printStackTrace(System.out);
            print ("\n");
          } finally {
            instance.tearDown();
            i++;
          }
        }
      }
    } catch (Exception e) {
      print(e);
      e.printStackTrace(System.out);
    } finally {
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
  
  void assertEqual(Object a, Object b, String message) {
    assertTrue(a.equals(b), message);   
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
  
}
