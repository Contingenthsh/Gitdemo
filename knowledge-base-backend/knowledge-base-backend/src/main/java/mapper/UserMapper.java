package com.doc.system.mapper;

import com.doc.system.entity.User;
import org.apache.ibatis.annotations.Select;
import org.springframework.stereotype.Repository;

@Repository
public interface UserMapper {
    @Select("select * from user where username = #{username}")
    User findByUsername(String username);
}