package com.amplifyframework.datastore.generated.model;

import com.amplifyframework.core.model.temporal.Temporal;

import java.util.List;
import java.util.UUID;
import java.util.Objects;

import androidx.core.util.ObjectsCompat;

import com.amplifyframework.core.model.AuthStrategy;
import com.amplifyframework.core.model.Model;
import com.amplifyframework.core.model.ModelOperation;
import com.amplifyframework.core.model.annotations.AuthRule;
import com.amplifyframework.core.model.annotations.Index;
import com.amplifyframework.core.model.annotations.ModelConfig;
import com.amplifyframework.core.model.annotations.ModelField;
import com.amplifyframework.core.model.query.predicate.QueryField;

import static com.amplifyframework.core.model.query.predicate.QueryField.field;

/** This is an auto generated class representing the UserSensorData type in your schema. */
@SuppressWarnings("all")
@ModelConfig(pluralName = "UserSensorData", authRules = {
  @AuthRule(allow = AuthStrategy.OWNER, ownerField = "owner", identityClaim = "cognito:username", provider = "userPools", operations = { ModelOperation.CREATE, ModelOperation.UPDATE, ModelOperation.DELETE, ModelOperation.READ }),
  @AuthRule(allow = AuthStrategy.PRIVATE, operations = { ModelOperation.CREATE, ModelOperation.UPDATE, ModelOperation.DELETE, ModelOperation.READ })
})
public final class UserSensorData implements Model {
  public static final QueryField ID = field("UserSensorData", "id");
  public static final QueryField USERNAME = field("UserSensorData", "username");
  public static final QueryField TIMESTAMP = field("UserSensorData", "timestamp");
  public static final QueryField ACC0 = field("UserSensorData", "acc0");
  public static final QueryField ACC1 = field("UserSensorData", "acc1");
  public static final QueryField ACC2 = field("UserSensorData", "acc2");
  public static final QueryField GYRO0 = field("UserSensorData", "gyro0");
  public static final QueryField GYRO1 = field("UserSensorData", "gyro1");
  public static final QueryField GYRO2 = field("UserSensorData", "gyro2");
  public static final QueryField GYRO3 = field("UserSensorData", "gyro3");
  private final @ModelField(targetType="ID", isRequired = true) String id;
  private final @ModelField(targetType="String", isRequired = true) String username;
  private final @ModelField(targetType="String", isRequired = true) String timestamp;
  private final @ModelField(targetType="Float", isRequired = true) Double acc0;
  private final @ModelField(targetType="Float", isRequired = true) Double acc1;
  private final @ModelField(targetType="Float", isRequired = true) Double acc2;
  private final @ModelField(targetType="Float", isRequired = true) Double gyro0;
  private final @ModelField(targetType="Float", isRequired = true) Double gyro1;
  private final @ModelField(targetType="Float", isRequired = true) Double gyro2;
  private final @ModelField(targetType="Float", isRequired = true) Double gyro3;
  private @ModelField(targetType="AWSDateTime", isReadOnly = true) Temporal.DateTime createdAt;
  private @ModelField(targetType="AWSDateTime", isReadOnly = true) Temporal.DateTime updatedAt;
  public String getId() {
      return id;
  }
  
  public String getUsername() {
      return username;
  }
  
  public String getTimestamp() {
      return timestamp;
  }
  
  public Double getAcc0() {
      return acc0;
  }
  
  public Double getAcc1() {
      return acc1;
  }
  
  public Double getAcc2() {
      return acc2;
  }
  
  public Double getGyro0() {
      return gyro0;
  }
  
  public Double getGyro1() {
      return gyro1;
  }
  
  public Double getGyro2() {
      return gyro2;
  }
  
  public Double getGyro3() {
      return gyro3;
  }
  
  public Temporal.DateTime getCreatedAt() {
      return createdAt;
  }
  
  public Temporal.DateTime getUpdatedAt() {
      return updatedAt;
  }
  
  private UserSensorData(String id, String username, String timestamp, Double acc0, Double acc1, Double acc2, Double gyro0, Double gyro1, Double gyro2, Double gyro3) {
    this.id = id;
    this.username = username;
    this.timestamp = timestamp;
    this.acc0 = acc0;
    this.acc1 = acc1;
    this.acc2 = acc2;
    this.gyro0 = gyro0;
    this.gyro1 = gyro1;
    this.gyro2 = gyro2;
    this.gyro3 = gyro3;
  }
  
  @Override
   public boolean equals(Object obj) {
      if (this == obj) {
        return true;
      } else if(obj == null || getClass() != obj.getClass()) {
        return false;
      } else {
      UserSensorData userSensorData = (UserSensorData) obj;
      return ObjectsCompat.equals(getId(), userSensorData.getId()) &&
              ObjectsCompat.equals(getUsername(), userSensorData.getUsername()) &&
              ObjectsCompat.equals(getTimestamp(), userSensorData.getTimestamp()) &&
              ObjectsCompat.equals(getAcc0(), userSensorData.getAcc0()) &&
              ObjectsCompat.equals(getAcc1(), userSensorData.getAcc1()) &&
              ObjectsCompat.equals(getAcc2(), userSensorData.getAcc2()) &&
              ObjectsCompat.equals(getGyro0(), userSensorData.getGyro0()) &&
              ObjectsCompat.equals(getGyro1(), userSensorData.getGyro1()) &&
              ObjectsCompat.equals(getGyro2(), userSensorData.getGyro2()) &&
              ObjectsCompat.equals(getGyro3(), userSensorData.getGyro3()) &&
              ObjectsCompat.equals(getCreatedAt(), userSensorData.getCreatedAt()) &&
              ObjectsCompat.equals(getUpdatedAt(), userSensorData.getUpdatedAt());
      }
  }
  
  @Override
   public int hashCode() {
    return new StringBuilder()
      .append(getId())
      .append(getUsername())
      .append(getTimestamp())
      .append(getAcc0())
      .append(getAcc1())
      .append(getAcc2())
      .append(getGyro0())
      .append(getGyro1())
      .append(getGyro2())
      .append(getGyro3())
      .append(getCreatedAt())
      .append(getUpdatedAt())
      .toString()
      .hashCode();
  }
  
  @Override
   public String toString() {
    return new StringBuilder()
      .append("UserSensorData {")
      .append("id=" + String.valueOf(getId()) + ", ")
      .append("username=" + String.valueOf(getUsername()) + ", ")
      .append("timestamp=" + String.valueOf(getTimestamp()) + ", ")
      .append("acc0=" + String.valueOf(getAcc0()) + ", ")
      .append("acc1=" + String.valueOf(getAcc1()) + ", ")
      .append("acc2=" + String.valueOf(getAcc2()) + ", ")
      .append("gyro0=" + String.valueOf(getGyro0()) + ", ")
      .append("gyro1=" + String.valueOf(getGyro1()) + ", ")
      .append("gyro2=" + String.valueOf(getGyro2()) + ", ")
      .append("gyro3=" + String.valueOf(getGyro3()) + ", ")
      .append("createdAt=" + String.valueOf(getCreatedAt()) + ", ")
      .append("updatedAt=" + String.valueOf(getUpdatedAt()))
      .append("}")
      .toString();
  }
  
  public static UsernameStep builder() {
      return new Builder();
  }
  
  /**
   * WARNING: This method should not be used to build an instance of this object for a CREATE mutation.
   * This is a convenience method to return an instance of the object with only its ID populated
   * to be used in the context of a parameter in a delete mutation or referencing a foreign key
   * in a relationship.
   * @param id the id of the existing item this instance will represent
   * @return an instance of this model with only ID populated
   */
  public static UserSensorData justId(String id) {
    return new UserSensorData(
      id,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null
    );
  }
  
  public CopyOfBuilder copyOfBuilder() {
    return new CopyOfBuilder(id,
      username,
      timestamp,
      acc0,
      acc1,
      acc2,
      gyro0,
      gyro1,
      gyro2,
      gyro3);
  }
  public interface UsernameStep {
    TimestampStep username(String username);
  }
  

  public interface TimestampStep {
    Acc0Step timestamp(String timestamp);
  }
  

  public interface Acc0Step {
    Acc1Step acc0(Double acc0);
  }
  

  public interface Acc1Step {
    Acc2Step acc1(Double acc1);
  }
  

  public interface Acc2Step {
    Gyro0Step acc2(Double acc2);
  }
  

  public interface Gyro0Step {
    Gyro1Step gyro0(Double gyro0);
  }
  

  public interface Gyro1Step {
    Gyro2Step gyro1(Double gyro1);
  }
  

  public interface Gyro2Step {
    Gyro3Step gyro2(Double gyro2);
  }
  

  public interface Gyro3Step {
    BuildStep gyro3(Double gyro3);
  }
  

  public interface BuildStep {
    UserSensorData build();
    BuildStep id(String id);
  }
  

  public static class Builder implements UsernameStep, TimestampStep, Acc0Step, Acc1Step, Acc2Step, Gyro0Step, Gyro1Step, Gyro2Step, Gyro3Step, BuildStep {
    private String id;
    private String username;
    private String timestamp;
    private Double acc0;
    private Double acc1;
    private Double acc2;
    private Double gyro0;
    private Double gyro1;
    private Double gyro2;
    private Double gyro3;
    @Override
     public UserSensorData build() {
        String id = this.id != null ? this.id : UUID.randomUUID().toString();
        
        return new UserSensorData(
          id,
          username,
          timestamp,
          acc0,
          acc1,
          acc2,
          gyro0,
          gyro1,
          gyro2,
          gyro3);
    }
    
    @Override
     public TimestampStep username(String username) {
        Objects.requireNonNull(username);
        this.username = username;
        return this;
    }
    
    @Override
     public Acc0Step timestamp(String timestamp) {
        Objects.requireNonNull(timestamp);
        this.timestamp = timestamp;
        return this;
    }
    
    @Override
     public Acc1Step acc0(Double acc0) {
        Objects.requireNonNull(acc0);
        this.acc0 = acc0;
        return this;
    }
    
    @Override
     public Acc2Step acc1(Double acc1) {
        Objects.requireNonNull(acc1);
        this.acc1 = acc1;
        return this;
    }
    
    @Override
     public Gyro0Step acc2(Double acc2) {
        Objects.requireNonNull(acc2);
        this.acc2 = acc2;
        return this;
    }
    
    @Override
     public Gyro1Step gyro0(Double gyro0) {
        Objects.requireNonNull(gyro0);
        this.gyro0 = gyro0;
        return this;
    }
    
    @Override
     public Gyro2Step gyro1(Double gyro1) {
        Objects.requireNonNull(gyro1);
        this.gyro1 = gyro1;
        return this;
    }
    
    @Override
     public Gyro3Step gyro2(Double gyro2) {
        Objects.requireNonNull(gyro2);
        this.gyro2 = gyro2;
        return this;
    }
    
    @Override
     public BuildStep gyro3(Double gyro3) {
        Objects.requireNonNull(gyro3);
        this.gyro3 = gyro3;
        return this;
    }
    
    /**
     * @param id id
     * @return Current Builder instance, for fluent method chaining
     */
    public BuildStep id(String id) {
        this.id = id;
        return this;
    }
  }
  

  public final class CopyOfBuilder extends Builder {
    private CopyOfBuilder(String id, String username, String timestamp, Double acc0, Double acc1, Double acc2, Double gyro0, Double gyro1, Double gyro2, Double gyro3) {
      super.id(id);
      super.username(username)
        .timestamp(timestamp)
        .acc0(acc0)
        .acc1(acc1)
        .acc2(acc2)
        .gyro0(gyro0)
        .gyro1(gyro1)
        .gyro2(gyro2)
        .gyro3(gyro3);
    }
    
    @Override
     public CopyOfBuilder username(String username) {
      return (CopyOfBuilder) super.username(username);
    }
    
    @Override
     public CopyOfBuilder timestamp(String timestamp) {
      return (CopyOfBuilder) super.timestamp(timestamp);
    }
    
    @Override
     public CopyOfBuilder acc0(Double acc0) {
      return (CopyOfBuilder) super.acc0(acc0);
    }
    
    @Override
     public CopyOfBuilder acc1(Double acc1) {
      return (CopyOfBuilder) super.acc1(acc1);
    }
    
    @Override
     public CopyOfBuilder acc2(Double acc2) {
      return (CopyOfBuilder) super.acc2(acc2);
    }
    
    @Override
     public CopyOfBuilder gyro0(Double gyro0) {
      return (CopyOfBuilder) super.gyro0(gyro0);
    }
    
    @Override
     public CopyOfBuilder gyro1(Double gyro1) {
      return (CopyOfBuilder) super.gyro1(gyro1);
    }
    
    @Override
     public CopyOfBuilder gyro2(Double gyro2) {
      return (CopyOfBuilder) super.gyro2(gyro2);
    }
    
    @Override
     public CopyOfBuilder gyro3(Double gyro3) {
      return (CopyOfBuilder) super.gyro3(gyro3);
    }
  }
  
}
