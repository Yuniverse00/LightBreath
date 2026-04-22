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

/** This is an auto generated class representing the UserInfo type in your schema. */
@SuppressWarnings("all")
@ModelConfig(pluralName = "UserInfos", authRules = {
  @AuthRule(allow = AuthStrategy.OWNER, ownerField = "owner", identityClaim = "cognito:username", provider = "userPools", operations = { ModelOperation.CREATE, ModelOperation.UPDATE, ModelOperation.DELETE, ModelOperation.READ }),
  @AuthRule(allow = AuthStrategy.PRIVATE, operations = { ModelOperation.CREATE, ModelOperation.UPDATE, ModelOperation.DELETE, ModelOperation.READ })
})
public final class UserInfo implements Model {
  public static final QueryField ID = field("UserInfo", "id");
  public static final QueryField USERNAME = field("UserInfo", "username");
  public static final QueryField TIMESTAMP = field("UserInfo", "timestamp");
  public static final QueryField PRICE = field("UserInfo", "price");
  public static final QueryField COUNT = field("UserInfo", "count");
  public static final QueryField TIME = field("UserInfo", "time");
  private final @ModelField(targetType="ID", isRequired = true) String id;
  private final @ModelField(targetType="String", isRequired = true) String username;
  private final @ModelField(targetType="String", isRequired = true) String timestamp;
  private final @ModelField(targetType="Float", isRequired = true) Double price;
  private final @ModelField(targetType="Int", isRequired = true) Integer count;
  private final @ModelField(targetType="Int", isRequired = true) Integer time;
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
  
  public Double getPrice() {
      return price;
  }
  
  public Integer getCount() {
      return count;
  }
  
  public Integer getTime() {
      return time;
  }
  
  public Temporal.DateTime getCreatedAt() {
      return createdAt;
  }
  
  public Temporal.DateTime getUpdatedAt() {
      return updatedAt;
  }
  
  private UserInfo(String id, String username, String timestamp, Double price, Integer count, Integer time) {
    this.id = id;
    this.username = username;
    this.timestamp = timestamp;
    this.price = price;
    this.count = count;
    this.time = time;
  }
  
  @Override
   public boolean equals(Object obj) {
      if (this == obj) {
        return true;
      } else if(obj == null || getClass() != obj.getClass()) {
        return false;
      } else {
      UserInfo userInfo = (UserInfo) obj;
      return ObjectsCompat.equals(getId(), userInfo.getId()) &&
              ObjectsCompat.equals(getUsername(), userInfo.getUsername()) &&
              ObjectsCompat.equals(getTimestamp(), userInfo.getTimestamp()) &&
              ObjectsCompat.equals(getPrice(), userInfo.getPrice()) &&
              ObjectsCompat.equals(getCount(), userInfo.getCount()) &&
              ObjectsCompat.equals(getTime(), userInfo.getTime()) &&
              ObjectsCompat.equals(getCreatedAt(), userInfo.getCreatedAt()) &&
              ObjectsCompat.equals(getUpdatedAt(), userInfo.getUpdatedAt());
      }
  }
  
  @Override
   public int hashCode() {
    return new StringBuilder()
      .append(getId())
      .append(getUsername())
      .append(getTimestamp())
      .append(getPrice())
      .append(getCount())
      .append(getTime())
      .append(getCreatedAt())
      .append(getUpdatedAt())
      .toString()
      .hashCode();
  }
  
  @Override
   public String toString() {
    return new StringBuilder()
      .append("UserInfo {")
      .append("id=" + String.valueOf(getId()) + ", ")
      .append("username=" + String.valueOf(getUsername()) + ", ")
      .append("timestamp=" + String.valueOf(getTimestamp()) + ", ")
      .append("price=" + String.valueOf(getPrice()) + ", ")
      .append("count=" + String.valueOf(getCount()) + ", ")
      .append("time=" + String.valueOf(getTime()) + ", ")
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
  public static UserInfo justId(String id) {
    return new UserInfo(
      id,
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
      price,
      count,
      time);
  }
  public interface UsernameStep {
    TimestampStep username(String username);
  }
  

  public interface TimestampStep {
    PriceStep timestamp(String timestamp);
  }
  

  public interface PriceStep {
    CountStep price(Double price);
  }
  

  public interface CountStep {
    TimeStep count(Integer count);
  }
  

  public interface TimeStep {
    BuildStep time(Integer time);
  }
  

  public interface BuildStep {
    UserInfo build();
    BuildStep id(String id);
  }
  

  public static class Builder implements UsernameStep, TimestampStep, PriceStep, CountStep, TimeStep, BuildStep {
    private String id;
    private String username;
    private String timestamp;
    private Double price;
    private Integer count;
    private Integer time;
    @Override
     public UserInfo build() {
        String id = this.id != null ? this.id : UUID.randomUUID().toString();
        
        return new UserInfo(
          id,
          username,
          timestamp,
          price,
          count,
          time);
    }
    
    @Override
     public TimestampStep username(String username) {
        Objects.requireNonNull(username);
        this.username = username;
        return this;
    }
    
    @Override
     public PriceStep timestamp(String timestamp) {
        Objects.requireNonNull(timestamp);
        this.timestamp = timestamp;
        return this;
    }
    
    @Override
     public CountStep price(Double price) {
        Objects.requireNonNull(price);
        this.price = price;
        return this;
    }
    
    @Override
     public TimeStep count(Integer count) {
        Objects.requireNonNull(count);
        this.count = count;
        return this;
    }
    
    @Override
     public BuildStep time(Integer time) {
        Objects.requireNonNull(time);
        this.time = time;
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
    private CopyOfBuilder(String id, String username, String timestamp, Double price, Integer count, Integer time) {
      super.id(id);
      super.username(username)
        .timestamp(timestamp)
        .price(price)
        .count(count)
        .time(time);
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
     public CopyOfBuilder price(Double price) {
      return (CopyOfBuilder) super.price(price);
    }
    
    @Override
     public CopyOfBuilder count(Integer count) {
      return (CopyOfBuilder) super.count(count);
    }
    
    @Override
     public CopyOfBuilder time(Integer time) {
      return (CopyOfBuilder) super.time(time);
    }
  }
  
}
