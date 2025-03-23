import React from 'react';
import styled from 'styled-components';

const ButtonWrapper = styled.div`
  position: relative;
  width: 96px;
  height: 96px;
  display: flex;
  justify-content: center;
  align-items: center;
`;

const OuterCircle = styled.div`
  position: absolute;
  width: 96px;
  height: 96px;
  border: 6px solid #FFFFFF;
  border-radius: 60px;
  box-sizing: border-box;
`;

const InnerButton = styled.button`
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 22px 30px;
  gap: 4px;
  width: 84px;
  height: 84px;
  background: #006AF5;
  border: 6px solid #A9C0FF;
  border-radius: 50px;
  cursor: pointer;
  transition: all 0.3s ease;

  &:hover {
    background: #0055cc;
  }
`;

const EditIcon = styled.div`
  width: 24px;
  height: 24px;
  position: relative;
  
  &:before {
    content: '';
    position: absolute;
    left: 8.33%;
    right: 8.33%;
    top: 8.33%;
    bottom: 8.33%;
    border: 1.5px solid #FFFFFF;
  }
`;

const ButtonText = styled.span`
  font-family: 'Roboto', sans-serif;
  font-style: normal;
  font-weight: 400;
  font-size: 12px;
  line-height: 14px;
  color: #FFFFFF;
`;

const PostButton: React.FC = () => {
  return (
    <ButtonWrapper>
      <OuterCircle />
      <InnerButton>
        <EditIcon />
        <ButtonText>Đăng tin</ButtonText>
      </InnerButton>
    </ButtonWrapper>
  );
};

export default PostButton; 